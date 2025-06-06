# frozen_string_literal: true

# Copyright (C) 2011 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

class UserList
  # Initialize a new UserList.
  #
  # open_registration is true, false, or nil. if nil, it defaults to root_account.open_registration?
  #
  # ==== Arguments
  # * <tt>list_in</tt> - either a comma/semi-colon/newline separated string or an array of paths
  # * <tt>options</tt> - a hash of additional optional data.
  #
  # ==== Options
  # * <tt>:search_method</tt> - configures how e-mails are handled. Defaults to :infer.
  # * <tt>:root_account</tt> - the account to use as the root account. Defaults to Account.default
  # * <tt>:initial_type</tt> - the initial enrollment type used for creating any new users.
  #                            Value is used when setting a new user's 'initial_enrollment_type'.
  #                            Defaults to +nil+.
  #
  # ==== Search Methods
  # The supported list of search methods.
  #
  # * <tt>:open</tt> - e-mails that don't match a pseudonym always create temporary users
  # * <tt>:closed</tt> - e-mails must belong to a user
  # * <tt>:preferred</tt> - if the e-mail belongs to a single user, that user
  #                         is used. otherwise a temporary user is created
  # * <tt>:infer</tt> - uses :open or :closed according to root_account.open_registration
  #
  def initialize(list_in,
                 root_account: Account.default,
                 search_method: :infer,
                 initial_type: nil,
                 current_user: nil)
    @addresses = []
    @errors = []
    @duplicate_addresses = []
    @root_account = root_account
    @search_method = search_method
    @initial_type = initial_type
    @search_method = (@root_account.open_registration? ? :open : :closed) if @search_method == :infer
    @current_user = current_user
    list_in ||= ""
    parse_list(list_in)
    resolve
  end

  attr_reader :errors, :addresses, :duplicate_addresses

  def as_json(*)
    {
      users: addresses.map { |a| a.except(:shard) },
      duplicates: duplicate_addresses,
      errored_users: errors
    }
  end

  def users
    existing = @addresses.select { |a| a[:user_id] }
    existing_users = Shard.partition_by_shard(existing, ->(a) { a[:shard] }) do |shard_existing|
      User.where(id: shard_existing.pluck(:user_id))
    end

    non_existing = @addresses.reject { |a| a[:user_id] }
    non_existing_users = non_existing.map do |a|
      user = User.new(name: a[:name] || a[:address])
      cc = user.communication_channels.build(path: a[:address], path_type: "email")
      cc.user = user
      user.workflow_state = "creation_pending"
      user.root_account_ids = [@root_account.id]
      user.initial_enrollment_type = User.initial_enrollment_type_from_text(@initial_type)
      user.save!
      user
    end
    existing_users + non_existing_users
  end

  private

  module Parsing
    def parse_single_user(path)
      return if path.blank?

      unique_id_regex = Pseudonym.validators
                                 .find { |v| v.attributes.include?(:unique_id) && v.is_a?(ActiveModel::Validations::FormatValidator) }
                                 .options[:with]
      # look for phone numbers by searching for 10 digits, allowing
      # any non-word characters
      if /^([^\d\w]*\d[^\d\w]*){10}$/.match?(path)
        type = :sms
      elsif path.include?("@") && (email = parse_email(path))
        type = :email
        name, path = email
      elsif path&.match?(unique_id_regex)
        type = :pseudonym
      else
        @errors << { address: path, details: :unparseable }
        return
      end

      @addresses << { name:, address: path, type: }
    end

    def parse_email(email)
      case email
      when /^(["'])(.*?[^\\])\1\s*<(\S+?@\S+?)>/
        a, b = $2, $3
        a = a.gsub(/\\(["'])/, '\1')
        [a, b]
      when /\s*(.+?)\s*<(\S+?@\S+?)>/
        [$1, $2]
      when /<(\S+?@\S+?)>/,
           /(\S+?@\S+)/
        [nil, $1]
      else
        nil
      end
    end

    def quote_ends(chars, i)
      loop do
        i += 1
        return false if i >= chars.size
        return false if chars[i] == "@"
        return true if chars[i] == '"'
      end
    end

    def parse_list(list_in)
      if list_in.is_a?(Array)
        list = list_in.map(&:strip)
        list.each { |path| parse_single_user(path) }
      else
        str = list_in.strip.gsub(/“|”/, "\"").gsub(/\n+/, ",").gsub(/\s+/, " ").tr(";", ",") + ","
        chars = str.chars
        user_start = 0
        in_quotes = false
        chars.each_with_index do |char, i|
          if in_quotes
            in_quotes = false if char == '"'
          else
            case char
            when ","
              user_line = str[user_start, i - user_start].strip
              parse_single_user(user_line) unless user_line.blank?
              user_start = i + 1
            when '"'
              in_quotes = true if quote_ends(chars, i)
            end
          end
        end
      end
    end
  end
  include Parsing

  def resolve
    trusted_account_ids = @root_account.trusted_account_ids
    if @current_user && (!@current_user.associated_shards.include?(Account.site_admin.shard) ||
        !Account.site_admin.pseudonyms.active.merge(@current_user.pseudonyms).exists?)
      trusted_account_ids.delete(Account.site_admin.id)
    end
    all_account_ids = [@root_account.id] + trusted_account_ids
    associated_shards = @addresses.map { |x| Pseudonym.associated_shards(x[:address].downcase) }.flatten.to_set
    associated_shards << @root_account.shard
    # Search for matching pseudonyms
    unless @addresses.empty?
      Shard.partition_by_shard(all_account_ids) do |account_ids|
        next if GlobalLookups.enabled? && !associated_shards.include?(Shard.current)

        unique_ids = Pseudonym.by_unique_id(@addresses.pluck(:address))
                              .or(Pseudonym.where(sis_user_id: @addresses.pluck(:address)))
        Pseudonym.active
                 .select("unique_id AS address, (SELECT name FROM #{User.quoted_table_name} WHERE users.id=user_id) AS name, user_id, account_id, sis_user_id")
                 .where(account_id: account_ids)
                 .merge(unique_ids)
                 .map { |pseudonym| pseudonym.attributes.symbolize_keys }.each do |login|
          addresses = @addresses.select do |a|
            a[:address].casecmp?(login[:address]) ||
              (login[:sis_user_id] && (a[:address] == login[:sis_user_id] || a[:sis_user_id] == login[:sis_user_id]))
          end
          addresses.each do |address|
            # already found a matching pseudonym
            if address[:user_id]
              # we already have the one from this-account, just go with it
              next if address[:account_id] == @root_account.local_id && address[:shard] == @root_account.shard

              # neither is from this-account, flag an error
              if (login[:account_id] != @root_account.local_id || Shard.current != @root_account.shard) &&
                 (login[:user_id] != address[:user_id] || Shard.current != address[:shard])
                address[:type] = :pseudonym if address[:type] == :email
                address[:user_id] = false
                address[:details] = :non_unique
                address.delete(:name)
                address.delete(:shard)
                next
              end
              # allow this one to overrule, since it's from this-account
              address.delete(:details)
            end
            address.merge!(login)
            address[:type] = :pseudonym
            address[:shard] = Shard.current
          end
        end
      end
    end

    # Search for matching emails (only if not open registration; otherwise there's no point - we just
    # create temporary users)
    emails = @addresses.select { |a| a[:type] == :email } if @search_method != :open
    associated_shards = @addresses.map { |x| CommunicationChannel.associated_shards(x[:address].downcase) }.flatten.to_set
    associated_shards << @root_account.shard
    if @search_method != :open && !emails.empty?
      Shard.partition_by_shard(all_account_ids) do |account_ids|
        next if GlobalLookups.enabled? && !associated_shards.include?(Shard.current)

        pseudos = Pseudonym.active
                           .select("path AS address, users.name AS name, communication_channels.user_id AS user_id, communication_channels.workflow_state AS workflow_state")
                           .joins(user: :communication_channels)
                           .where("LOWER(path) IN (?) AND account_id IN (?)", emails.map { |x| x[:address].downcase }, account_ids)
        pseudos = if @root_account.feature_enabled?(:allow_unconfirmed_users_in_user_list)
                    pseudos.merge(CommunicationChannel.unretired)
                  else
                    pseudos.merge(CommunicationChannel.active)
                  end

        pseudos.map { |pseudonym| pseudonym.attributes.symbolize_keys }.each do |login|
          addresses = emails.select { |a| a[:address].casecmp?(login[:address]) }
          addresses.each do |address|
            # if all we've seen is unconfirmed, and this one is active, we'll allow this one to overrule
            if address[:workflow_state] == "unconfirmed" && login[:workflow_state] == "active"
              address.delete(:user_id)
              address.delete(:details)
              address.delete(:shard)
            end
            # if we've seen an active, and this one is unconfirmed, skip it
            next if address[:workflow_state] == "active" && login[:workflow_state] == "unconfirmed"

            # ccs are not unique; just error out on duplicates
            # we're in a bit of a pickle if open registration is disabled, and there are conflicting
            # e-mails, but none of them are from a pseudonym
            if address.key?(:user_id) && (address[:user_id] != login[:user_id] || address[:shard] != Shard.current)
              address[:user_id] = false
              address[:details] = :non_unique
              address.delete(:name)
              address.delete(:shard)
            else
              address.merge!(login)
              address[:shard] = Shard.current
            end
          end
        end
      end
    end

    # Search for matching SMS
    smses = @addresses.select { |a| a[:type] == :sms }
    # reformat
    smses.each do |sms|
      number = sms[:address].gsub(/[^\d\w]/, "")
      sms[:address] = "(#{number[0, 3]}) #{number[3, 3]}-#{number[6, 4]}"
    end
    sms_account_ids = (@search_method == :closed) ? all_account_ids : [@root_account]
    unless smses.empty?
      Shard.partition_by_shard(sms_account_ids) do |account_ids|
        sms_scope = (@search_method == :closed) ? Pseudonym.where(account_id: account_ids) : Pseudonym
        sms_scope.active
                 .select("path AS address, users.name AS name, communication_channels.user_id AS user_id")
                 .joins(user: :communication_channels)
                 .where("communication_channels.workflow_state='active' AND (#{smses.map { |x| "path LIKE '#{x[:address].gsub(/[^\d]/, "")}%'" }.join(" OR ")})")
                 .map { |pseudonym| pseudonym.attributes.symbolize_keys }.each do |sms|
          address = sms.delete(:address)[/\d+/]
          addresses = smses.select { |a| a[:address].gsub(/[^\d]/, "") == address }
          addresses.each do |a|
            # ccs are not unique; just error out on duplicates
            if a.key?(:user_id) && (a[:user_id] != login[:user_id] || a[:shard] != Shard.current)
              a[:user_id] = false
              a[:details] = :non_unique
              a.delete(:name)
              a.delete(:shard)
            else
              sms[:user_id] = sms[:user_id].to_i
              a.merge!(sms)
              a[:shard] = Shard.current
            end
          end
        end
      end
    end

    all_addresses = @addresses
    @addresses = []
    all_addresses.each do |address|
      # This is temporary working data
      address.delete :workflow_state
      address.delete :account_id
      address.delete :sis_user_id
      address.delete :id
      # Only allow addresses that we found a user, or that we can implicitly create the user
      if address[:user_id].present?
        ((@addresses.find { |a| a[:user_id] == address[:user_id] && a[:shard] == address[:shard] }) ? @duplicate_addresses : @addresses) << address
      elsif address[:type] == :email && @search_method == :open
        ((@addresses.find { |a| a[:address].casecmp?(address[:address]) }) ? @duplicate_addresses : @addresses) << address
      elsif @search_method == :preferred && (address[:details] == :non_unique || address[:type] == :email)
        address.delete :user_id
        ((@addresses.find { |a| a[:address].casecmp?(address[:address]) }) ? @duplicate_addresses : @addresses) << address
      else
        @errors << { address: address[:address], type: address[:type], details: address[:details] || :not_found }
      end
    end
  end
end
