# frozen_string_literal: true

#
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

# @API SIS Imports
#
# API for importing data from Student Information Systems
#
# @model SisImportData
#     {
#       "id": "SisImportData",
#       "description": "",
#       "properties": {
#         "import_type": {
#           "description": "The type of SIS import",
#           "example": "instructure_csv",
#           "type": "string"
#         },
#         "supplied_batches": {
#           "description": "Which files were included in the SIS import",
#           "example": ["term", "course", "section", "user", "enrollment"],
#           "type": "array",
#           "items": { "type": "string" }
#         },
#         "counts": {
#           "description": "The number of rows processed for each type of import",
#           "$ref": "SisImportCounts"
#         }
#       }
#     }
#
# @model SisImportStatistic
#     {
#       "id": "SisImportStatistic",
#       "description": "",
#       "properties": {
#         "created": {
#           "description": "This is the number of items that were created.",
#           "example": 18,
#           "type": "integer"
#         },
#         "concluded": {
#           "description": "This is the number of items that marked as completed. This only applies to courses and enrollments.",
#           "example": 3,
#           "type": "integer"
#         },
#         "deactivated": {
#           "description": "This is the number of Enrollments that were marked as 'inactive'. This only applies to enrollments.",
#           "example": 1,
#           "type": "integer"
#         },
#         "restored": {
#           "description": "This is the number of items that were set to an active state from a completed, inactive, or deleted state.",
#           "example": 2,
#           "type": "integer"
#         },
#         "deleted": {
#           "description": "This is the number of items that were deleted.",
#           "example": 40,
#           "type": "integer"
#         }
#       }
#     }
#
# @model SisImportStatistics
#     {
#       "id": "SisImportStatistics",
#       "description": "",
#       "properties": {
#         "total_state_changes": {
#           "description": "This is the total number of items that were changed in the sis import. There are a few caveats that can cause this number to not add up to the individual counts. There are some state changes that happen that have no impact to the object. An example would be changing a course from 'created' to 'claimed'. Both of these would be considered an active course, but would increment this counter. In this example the course would not increment the created or restored counters for course statistic.",
#           "example": 382,
#           "type": "integer"
#         },
#         "Account": {
#           "description": "This contains that statistics for accounts.",
#           "$ref": "SisImportStatistic"
#         },
#         "EnrollmentTerm": {
#           "description": "This contains that statistics for terms.",
#           "$ref": "SisImportStatistic"
#         },
#         "CommunicationChannel": {
#           "description": "This contains that statistics for communication channels. This is an indirect effect from creating or deleting a user.",
#           "$ref": "SisImportStatistic"
#         },
#         "AbstractCourse": {
#           "description": "This contains that statistics for abstract courses.",
#           "$ref": "SisImportStatistic"
#         },
#         "Course": {
#           "description": "This contains that statistics for courses.",
#           "$ref": "SisImportStatistic"
#         },
#         "CourseSection": {
#           "description": "This contains that statistics for course sections.",
#           "$ref": "SisImportStatistic"
#         },
#         "Enrollment": {
#           "description": "This contains that statistics for enrollments.",
#           "$ref": "SisImportStatistic"
#         },
#         "GroupCategory": {
#           "description": "This contains that statistics for group categories.",
#           "$ref": "SisImportStatistic"
#         },
#         "Group": {
#           "description": "This contains that statistics for groups.",
#           "$ref": "SisImportStatistic"
#         },
#         "GroupMembership": {
#           "description": "This contains that statistics for group memberships. This can be a direct impact from the import or indirect from an enrollment being deleted.",
#           "$ref": "SisImportStatistic"
#         },
#         "Pseudonym": {
#           "description": "This contains that statistics for pseudonyms. Pseudonyms are logins for users, and are the object that ties an enrollment to a user. This would be impacted from the user importer. ",
#           "$ref": "SisImportStatistic"
#         },
#         "UserObserver": {
#           "description": "This contains that statistics for user observers.",
#           "$ref": "SisImportStatistic"
#         },
#         "AccountUser": {
#           "description": "This contains that statistics for account users.",
#           "$ref": "SisImportStatistic"
#         }
#       }
#     }
#
# @model SisImportCounts
#     {
#       "id": "SisImportCounts",
#       "description": "",
#       "properties": {
#         "accounts": {
#           "example": 0,
#           "type": "integer"
#         },
#         "terms": {
#           "example": 3,
#           "type": "integer"
#         },
#         "abstract_courses": {
#           "example": 0,
#           "type": "integer"
#         },
#         "courses": {
#           "example": 121,
#           "type": "integer"
#         },
#         "sections": {
#           "example": 278,
#           "type": "integer"
#         },
#         "xlists": {
#           "example": 0,
#           "type": "integer"
#         },
#         "users": {
#           "example": 346,
#           "type": "integer"
#         },
#         "enrollments": {
#           "example": 1542,
#           "type": "integer"
#         },
#         "groups": {
#           "example": 0,
#           "type": "integer"
#         },
#         "group_memberships": {
#           "example": 0,
#           "type": "integer"
#         },
#         "grade_publishing_results": {
#           "example": 0,
#           "type": "integer"
#         },
#         "batch_courses_deleted": {
#           "description": "the number of courses that were removed because they were not included in the batch for batch_mode imports. Only included if courses were deleted",
#           "example": 11,
#           "type": "integer"
#         },
#         "batch_sections_deleted": {
#           "description": "the number of sections that were removed because they were not included in the batch for batch_mode imports. Only included if sections were deleted",
#           "example": 0,
#           "type": "integer"
#         },
#         "batch_enrollments_deleted": {
#           "description": "the number of enrollments that were removed because they were not included in the batch for batch_mode imports. Only included if enrollments were deleted",
#           "example": 150,
#           "type": "integer"
#         },
#         "error_count": {
#           "example": 0,
#           "type": "integer"
#         },
#         "warning_count": {
#           "example": 0,
#           "type": "integer"
#         }
#       }
#     }
#
# @model SisImport
#     {
#       "id": "SisImport",
#       "description": "",
#       "properties": {
#         "id": {
#           "description": "The unique identifier for the SIS import.",
#           "example": 1,
#           "type": "integer"
#         },
#         "created_at": {
#           "description": "The date the SIS import was created.",
#           "example": "2013-12-01T23:59:00-06:00",
#           "type": "datetime"
#         },
#         "ended_at": {
#           "description": "The date the SIS import finished. Returns null if not finished.",
#           "example": "2013-12-02T00:03:21-06:00",
#           "type": "datetime"
#         },
#         "updated_at": {
#           "description": "The date the SIS import was last updated.",
#           "example": "2013-12-02T00:03:21-06:00",
#           "type": "datetime"
#         },
#         "workflow_state": {
#           "description": "The current state of the SIS import.\n - 'initializing': The SIS import is being created, if this gets stuck in initializing, it will not import and will continue on to next import.\n - 'created': The SIS import has been created.\n - 'importing': The SIS import is currently processing.\n - 'cleanup_batch': The SIS import is currently cleaning up courses, sections, and enrollments not included in the batch for batch_mode imports.\n - 'imported': The SIS import has completed successfully.\n - 'imported_with_messages': The SIS import completed with errors or warnings.\n - 'aborted': The SIS import was aborted.\n - 'failed_with_messages': The SIS import failed with errors.\n - 'failed': The SIS import failed.\n - 'restoring': The SIS import is restoring states of imported items.\n - 'partially_restored': The SIS import is restored some of the states of imported items. This is generally due to passing a param like undelete only.\n - 'restored': The SIS import is restored all of the states of imported items.",
#           "example": "imported",
#           "type": "string",
#           "allowableValues": {
#             "values": [
#               "initializing",
#               "created",
#               "importing",
#               "cleanup_batch",
#               "imported",
#               "imported_with_messages",
#               "aborted",
#               "failed",
#               "failed_with_messages",
#               "restoring",
#               "partially_restored",
#               "restored"
#             ]
#           }
#         },
#         "data": {
#           "description": "data",
#           "$ref": "SisImportData"
#         },
#         "statistics": {
#           "description": "statistics",
#           "$ref": "SisImportStatistics"
#         },
#         "progress": {
#           "description": "The progress of the SIS import. The progress will reset when using batch_mode and have a different progress for the cleanup stage",
#           "example": "100",
#           "type": "string"
#         },
#         "errors_attachment": {
#           "description": "The errors_attachment api object of the SIS import. Only available if there are errors or warning and import has completed.",
#           "$ref": "File"
#         },
#         "user": {
#           "description": "The user that initiated the sis_batch. See the Users API for details.",
#           "$ref": "User"
#         },
#         "processing_warnings": {
#           "description": "Only imports that are complete will get this data. An array of CSV_file/warning_message pairs.",
#           "example": [["students.csv","user John Doe has already claimed john_doe's requested login information, skipping"]],
#           "type": "array",
#           "items": {
#             "type": "array",
#             "items": {"type": "string"}
#           }
#         },
#         "processing_errors": {
#           "description": "An array of CSV_file/error_message pairs.",
#           "example": [["students.csv","Error while importing CSV. Please contact support."]],
#           "type": "array",
#           "items": {
#             "type": "array",
#             "items": {"type": "string"}
#           }
#         },
#         "batch_mode": {
#           "description": "Whether the import was run in batch mode.",
#           "example": "true",
#           "type": "boolean"
#         },
#         "batch_mode_term_id": {
#           "description": "The term the batch was limited to.",
#           "example": "1234",
#           "type": "string"
#         },
#         "multi_term_batch_mode": {
#           "description": "Enables batch mode against all terms in term file. Requires change_threshold to be set.",
#           "example": "false",
#           "type": "boolean"
#         },
#         "skip_deletes": {
#           "description": "When set the import will skip any deletes.",
#           "example": "false",
#           "type": "boolean"
#         },
#         "override_sis_stickiness": {
#           "description": "Whether UI changes were overridden.",
#           "example": "false",
#           "type": "boolean"
#         },
#         "add_sis_stickiness": {
#           "description": "Whether stickiness was added to the batch changes.",
#           "example": "false",
#           "type": "boolean"
#         },
#         "clear_sis_stickiness": {
#           "description": "Whether stickiness was cleared.",
#           "example": "false",
#           "type": "boolean"
#         },
#         "diffing_threshold_exceeded": {
#           "description": "Whether a diffing job failed because the threshold limit got exceeded.",
#           "example": "true",
#           "type": "boolean"
#         },
#         "diffing_data_set_identifier": {
#           "description": "The identifier of the data set that this SIS batch diffs against",
#           "example": "account-5-enrollments",
#           "type": "string"
#         },
#         "diffing_remaster": {
#           "description": "Whether diffing remaster data was enabled.",
#           "example": "false",
#           "type": "boolean"
#         },
#         "diffed_against_import_id": {
#           "description": "The ID of the SIS Import that this import was diffed against",
#           "example": 1,
#           "type": "integer"
#         },
#         "csv_attachments": {
#           "description": "An array of CSV files for processing",
#           "example": [],
#           "type": "array",
#           "items": {
#             "type": "array",
#             "items": {"$ref": "File"}
#           }
#         }
#       }
#     }
#
class SisImportsApiController < ApplicationController
  before_action :get_context
  before_action :check_account
  include Api::V1::SisImport
  include Api::V1::Progress

  def check_account
    return render json: { errors: ["SIS imports can only be executed on root accounts"] }, status: :bad_request unless @account.root_account?

    render json: { errors: ["SIS imports are not enabled for this account"] }, status: :forbidden unless @account.allow_sis_import
  end

  # @API Get SIS import list
  #
  # Returns the list of SIS imports for an account
  #
  # @argument created_since [Optional, DateTime]
  #   If set, only shows imports created after the specified date (use ISO8601 format)
  # @argument created_before [Optional, DateTime]
  #   If set, only shows imports created before the specified date (use ISO8601 format)
  #
  # @argument workflow_state[] [String, "initializing"|"created"|"importing"|"cleanup_batch"|"imported"|"imported_with_messages"|"aborted"|"failed"|"failed_with_messages"|"restoring"|"partially_restored"|"restored"]
  #   If set, only returns imports that are in the given state.
  #
  # Example:
  #   curl https://<canvas>/api/v1/accounts/<account_id>/sis_imports \
  #     -H 'Authorization: Bearer <token>'
  #
  # @returns [SisImport]
  def index
    if authorized_action(@account, @current_user, [:import_sis, :manage_sis])
      scope = @account.sis_batches.order("created_at DESC")
      if (created_since = CanvasTime.try_parse(params[:created_since]))
        scope = scope.where("created_at > ?", created_since)
      end
      if (created_before = CanvasTime.try_parse(params[:created_before]))
        scope = scope.where(created_at: ...created_before)
      end

      state = Array(params[:workflow_state]) & %w[initializing
                                                  created
                                                  importing
                                                  cleanup_batch
                                                  imported
                                                  imported_with_messages
                                                  aborted
                                                  failed
                                                  failed_with_messages
                                                  restoring
                                                  partially_restored
                                                  restored]
      scope = scope.where(workflow_state: state) if state.present?

      # we don't need to know how many there are
      @batches = Api.paginate(scope, self, api_v1_account_sis_imports_url, total_entries: nil)
      render json: { sis_imports: sis_imports_json(@batches, @current_user, session) }
    end
  end

  # @API Get the current importing SIS import
  #
  # Returns the SIS imports that are currently processing for an account. If no
  # imports are running, will return an empty array.
  #
  # Example:
  #   curl https://<canvas>/api/v1/accounts/<account_id>/sis_imports/importing \
  #     -H 'Authorization: Bearer <token>'
  #
  # @returns SisImport
  def importing
    if authorized_action(@account, @current_user, [:import_sis, :manage_sis])
      batches = @account.sis_batches.importing
      render json: { sis_imports: sis_imports_json(batches, @current_user, session) }
    end
  end

  # @API Import SIS data
  #
  # Import SIS data into Canvas. Must be on a root account with SIS imports
  # enabled.
  #
  # For more information on the format that's expected here, please see the
  # "SIS CSV" section in the API docs.
  #
  # @argument import_type [String]
  #   Choose the data format for reading SIS data. With a standard Canvas
  #   install, this option can only be 'instructure_csv', and if unprovided,
  #   will be assumed to be so. Can be part of the query string.
  #
  # @argument attachment
  #   There are two ways to post SIS import data - either via a
  #   multipart/form-data form-field-style attachment, or via a non-multipart
  #   raw post request.
  #
  #   'attachment' is required for multipart/form-data style posts. Assumed to
  #   be SIS data from a file upload form field named 'attachment'.
  #
  #   Examples:
  #     curl -F attachment=@<filename> -H "Authorization: Bearer <token>" \
  #         https://<canvas>/api/v1/accounts/<account_id>/sis_imports.json?import_type=instructure_csv
  #
  #   If you decide to do a raw post, you can skip the 'attachment' argument,
  #   but you will then be required to provide a suitable Content-Type header.
  #   You are encouraged to also provide the 'extension' argument.
  #
  #   Examples:
  #     curl -H 'Content-Type: application/octet-stream' --data-binary @<filename>.zip \
  #         -H "Authorization: Bearer <token>" \
  #         https://<canvas>/api/v1/accounts/<account_id>/sis_imports.json?import_type=instructure_csv&extension=zip
  #
  #     curl -H 'Content-Type: application/zip' --data-binary @<filename>.zip \
  #         -H "Authorization: Bearer <token>" \
  #         https://<canvas>/api/v1/accounts/<account_id>/sis_imports.json?import_type=instructure_csv
  #
  #     curl -H 'Content-Type: text/csv' --data-binary @<filename>.csv \
  #         -H "Authorization: Bearer <token>" \
  #         https://<canvas>/api/v1/accounts/<account_id>/sis_imports.json?import_type=instructure_csv
  #
  #     curl -H 'Content-Type: text/csv' --data-binary @<filename>.csv \
  #         -H "Authorization: Bearer <token>" \
  #         https://<canvas>/api/v1/accounts/<account_id>/sis_imports.json?import_type=instructure_csv&batch_mode=1&batch_mode_term_id=15
  #
  #   If the attachment is a zip file, the uncompressed file(s) cannot be 100x larger than the zip, or the import will fail.
  #   For example, if the zip file is 1KB but the total size of the uncompressed file(s) is 100KB or greater the import will
  #   fail. There is a hard cap of 50 GB.
  #
  # @argument extension [String]
  #   Recommended for raw post request style imports. This field will be used to
  #   distinguish between zip, xml, csv, and other file format extensions that
  #   would usually be provided with the filename in the multipart post request
  #   scenario. If not provided, this value will be inferred from the
  #   Content-Type, falling back to zip-file format if all else fails.
  #
  # @argument batch_mode [Boolean]
  #   If set, this SIS import will be run in batch mode, deleting any data
  #   previously imported via SIS that is not present in this latest import.
  #   See the SIS CSV Format page for details.
  #   Batch mode cannot be used with diffing.
  #
  # @argument batch_mode_term_id [String]
  #   Limit deletions to only this term. Required if batch mode is enabled.
  #
  # @argument multi_term_batch_mode [Boolean]
  #   Runs batch mode against all terms in terms file. Requires change_threshold.
  #
  # @argument skip_deletes [Boolean]
  #   When set the import will skip any deletes. This does not account for
  #   objects that are deleted during the batch mode cleanup process.
  #
  # @argument override_sis_stickiness [Boolean]
  #   Default is false. If true, any fields containing “sticky” or UI changes will be overridden.
  #   See SIS CSV Format documentation for information on which fields can have SIS stickiness
  #
  # @argument add_sis_stickiness [Boolean]
  #   This option, if present, will process all changes as if they were UI
  #   changes. This means that "stickiness" will be added to changed fields.
  #   This option is only processed if 'override_sis_stickiness' is also provided.
  #
  # @argument clear_sis_stickiness [Boolean]
  #   This option, if present, will clear "stickiness" from all fields processed
  #   by this import. Requires that 'override_sis_stickiness' is also provided.
  #   If 'add_sis_stickiness' is also provided, 'clear_sis_stickiness' will
  #   overrule the behavior of 'add_sis_stickiness'
  #
  # @argument update_sis_id_if_login_claimed [Boolean]
  #   This option, if present, will override the old (or non-existent)
  #   non-matching SIS ID with the new SIS ID in the upload,
  #   if a pseudonym is found from the login field and the SIS ID doesn't match.
  #
  # @argument diffing_data_set_identifier [String]
  #   If set on a CSV import, Canvas will attempt to optimize the SIS import by
  #   comparing this set of CSVs to the previous set that has the same data set
  #   identifier, and only applying the difference between the two. See the
  #   SIS CSV Format documentation for more details.
  #   Diffing cannot be used with batch_mode
  #
  # @argument diffing_remaster_data_set [Boolean]
  #   If true, and diffing_data_set_identifier is sent, this SIS import will be
  #   part of the data set, but diffing will not be performed. See the SIS CSV
  #   Format documentation for details.
  #
  # @argument diffing_drop_status [String, "deleted"|"completed"|"inactive"]
  #   If diffing_drop_status is passed, this SIS import will use this status for
  #   enrollments that are not included in the sis_batch. Defaults to 'deleted'
  #
  # @argument diffing_user_remove_status [String, "deleted"|"suspended"]
  #   For users removed from one batch to the next one using the same
  #   diffing_data_set_identifier, set their status to the value of this argument.
  #   Defaults to 'deleted'.
  #
  # @argument batch_mode_enrollment_drop_status [String, "deleted"|"completed"|"inactive"]
  #   If batch_mode_enrollment_drop_status is passed, this SIS import will use
  #   this status for enrollments that are not included in the sis_batch. This
  #   will have an effect if multi_term_batch_mode is set. Defaults to 'deleted'
  #   This will still mark courses and sections that are not included in the
  #   sis_batch as deleted, and subsequently enrollments in the deleted courses
  #   and sections as deleted.
  #
  # @argument change_threshold [Integer]
  #   If set with batch_mode, the batch cleanup process will not run if the
  #   number of items deleted is higher than the percentage set. If set to 10
  #   and a term has 200 enrollments, and batch would delete more than 20 of
  #   the enrollments the batch will abort before the enrollments are deleted.
  #   The change_threshold will be evaluated for course, sections, and
  #   enrollments independently.
  #   If set with diffing, diffing will not be performed if the files are
  #   greater than the threshold as a percent. If set to 5 and the file is more
  #   than 5% smaller or more than 5% larger than the file that is being
  #   compared to, diffing will not be performed. If the files are less than 5%,
  #   diffing will be performed. The way the percent is calculated is by taking
  #   the size of the current import and dividing it by the size of the previous
  #   import. The formula used is:
  #   |(1 - current_file_size / previous_file_size)| * 100
  #   See the SIS CSV Format documentation for more details.
  #   Required for multi_term_batch_mode.
  #
  # @argument diff_row_count_threshold [Integer]
  #   If set with diffing, diffing will not be performed if the number of rows
  #   to be run in the fully calculated diff import exceeds the threshold.
  #
  # @returns SisImport
  def create
    if authorized_action(@account, @current_user, :import_sis)
      params[:import_type] ||= "instructure_csv"
      raise "invalid import type parameter" unless SisBatch.valid_import_types.key?(params[:import_type])

      if !api_request? && @account.current_sis_batch.try(:importing?)
        return render json: { error: true, error_message: t(:sis_import_in_process_notice, "An SIS import is already in process."), batch_in_progress: true }
      end

      file_obj = nil
      if params.key?(:attachment)
        file_obj = params[:attachment]
      elsif request.media_type == "multipart/form-data"
        # don't interpret the form itself as a SIS batch
        return render json: { error: true, error_message: "Missing attachment" }, status: :bad_request
      else
        file_obj = request.body

        def file_obj.set_file_attributes(filename, content_type)
          @original_filename = filename
          @content_type = content_type
        end

        # rubocop:disable Style/TrivialAccessors -- not a Class
        def file_obj.content_type
          @content_type
        end

        def file_obj.original_filename
          @original_filename
        end
        # rubocop:enable Style/TrivialAccessors -- not a Class

        if params[:extension]
          file_obj.set_file_attributes("sis_import.#{params[:extension]}",
                                       Attachment.mimetype("sis_import.#{params[:extension]}"))
        else
          env = request.env.dup
          env["CONTENT_TYPE"] = env["ORIGINAL_CONTENT_TYPE"]
          # copy of request with original content type restored
          request2 = Rack::Request.new(env)
          charset = request2.media_type_params["charset"]
          if charset.present? && !charset.casecmp?("utf-8")
            return render json: { error: t("errors.invalid_content_type", "Invalid content type, UTF-8 required") }, status: :bad_request
          end

          params[:extension] ||= { "application/zip" => "zip",
                                   "text/xml" => "xml",
                                   "text/plain" => "csv",
                                   "text/csv" => "csv" }[request2.media_type] || "zip"
          file_obj.set_file_attributes("sis_import.#{params[:extension]}",
                                       request2.media_type)
        end
      end

      batch_mode_term = nil
      if value_to_boolean(params[:batch_mode])
        if params[:batch_mode_term_id].present?
          batch_mode_term = api_find(@account.enrollment_terms.active,
                                     params[:batch_mode_term_id])
        end
        unless batch_mode_term || params[:multi_term_batch_mode]
          return render json: { message: "Batch mode specified, but the given batch_mode_term_id cannot be found." }, status: :bad_request
        end
      end

      batch = SisBatch.create_with_attachment(@account, params[:import_type], file_obj, @current_user) do |batch| # rubocop:disable Lint/ShadowingOuterLocalVariable
        batch.change_threshold = params[:change_threshold]

        batch.options ||= {}
        if (threshold = params[:diff_row_count_threshold]&.to_i) && threshold > 0
          batch.options[:diff_row_count_threshold] = threshold
        end
        if batch_mode_term
          batch.batch_mode = true
          batch.batch_mode_term = batch_mode_term
        elsif params[:multi_term_batch_mode]
          batch.batch_mode = true
          batch.options[:multi_term_batch_mode] = value_to_boolean(params[:multi_term_batch_mode])
          unless batch.change_threshold
            return render json: { message: "change_threshold is required to use multi term_batch mode." }, status: :bad_request
          end
        elsif params[:diffing_data_set_identifier].present?
          batch.enable_diffing(params[:diffing_data_set_identifier],
                               value_to_boolean(params[:diffing_remaster_data_set]))
        end

        batch.options[:skip_deletes] = value_to_boolean(params[:skip_deletes])
        batch.options[:update_sis_id_if_login_claimed] = value_to_boolean(params[:update_sis_id_if_login_claimed])

        if value_to_boolean(params[:override_sis_stickiness])
          batch.options[:override_sis_stickiness] = true
          [:add_sis_stickiness, :clear_sis_stickiness].each do |option|
            batch.options[option] = true if value_to_boolean(params[option])
          end
        end
        if params[:diffing_drop_status].present?
          batch.options[:diffing_drop_status] = (Array(params[:diffing_drop_status]) & SIS::CSV::DiffGenerator::VALID_ENROLLMENT_DROP_STATUS).first
          return render json: { message: "Invalid diffing_drop_status" }, status: :bad_request unless batch.options[:diffing_drop_status]
        end
        if params[:diffing_user_remove_status].present?
          batch.options[:diffing_user_remove_status] = (Array(params[:diffing_user_remove_status]) & SIS::CSV::DiffGenerator::VALID_USER_REMOVE_STATUS).first
          return render json: { message: "Invalid diffing_user_remove_status" }, status: :bad_request unless batch.options[:diffing_user_remove_status]
        end
        if params[:batch_mode_enrollment_drop_status].present?
          batch.options[:batch_mode_enrollment_drop_status] = (Array(params[:batch_mode_enrollment_drop_status]) & SIS::CSV::DiffGenerator::VALID_ENROLLMENT_DROP_STATUS).first
          return render json: { message: "Invalid batch_mode_enrollment_drop_status" }, status: :bad_request unless batch.options[:batch_mode_enrollment_drop_status]
        end
      end

      batch.process

      unless api_request?
        @account.current_sis_batch_id = batch.id
        @account.save
      end

      render json: sis_import_json(batch, @current_user, session)
    end
  end

  # @API Get SIS import status
  #
  # Get the status of an already created SIS import.
  #
  #   Examples:
  #     curl https://<canvas>/api/v1/accounts/<account_id>/sis_imports/<sis_import_id> \
  #         -H 'Authorization: Bearer <token>'
  #
  # @returns SisImport
  def show
    if authorized_action(@account, @current_user, [:import_sis, :manage_sis])
      @batch = @account.sis_batches.find(params[:id])
      render json: sis_import_json(@batch, @current_user, session, includes: ["errors"])
    end
  end

  # @API Restore workflow_states of SIS imported items
  #
  # This will restore the the workflow_state for all the items that changed
  # their workflow_state during the import being restored.
  # This will restore states for items imported with the following importers:
  # accounts.csv terms.csv courses.csv sections.csv group_categories.csv
  # groups.csv users.csv admins.csv
  # This also restores states for other items that changed during the import.
  # An example would be if an enrollment was deleted from a sis import and the
  # group_membership was also deleted as a result of the enrollment deletion,
  # both items would be restored when the sis batch is restored.
  #
  # Restore data is retained for 30 days post-import. This endpoint is
  # unavailable after that time.
  #
  # @argument batch_mode [Boolean]
  #   If set, will only restore items that were deleted from batch_mode.
  #
  # @argument undelete_only [Boolean]
  #   If set, will only restore items that were deleted. This will ignore any
  #   items that were created or modified.
  #
  # @argument unconclude_only [Boolean]
  #   If set, will only restore enrollments that were concluded. This will
  #   ignore any items that were created or deleted.
  #
  # @example_request
  #   curl https://<canvas>/api/v1/accounts/<account_id>/sis_imports/<sis_import_id>/restore_states \
  #     -H 'Authorization: Bearer <token>'
  #
  # @returns Progress
  def restore_states
    if authorized_action(@account, @current_user, :manage_sis)
      @batch = @account.sis_batches.find(params[:id])
      unless @batch.roll_back_data.not_expired.exists?
        return render json: { message: "restore data unavailable" }, status: :bad_request
      end

      batch_mode = value_to_boolean(params[:batch_mode])
      undelete_only = value_to_boolean(params[:undelete_only])
      unconclude_only = value_to_boolean(params[:unconclude_only])
      if undelete_only && unconclude_only
        return render json: { message: "cannot set both undelete_only and unconclude_only" }, status: :bad_request
      end

      progress = @batch.restore_states_later(batch_mode:, undelete_only:, unconclude_only:)
      render json: progress_json(progress, @current_user, session)
    end
  end

  # @API Abort SIS import
  #
  # Abort a SIS import that has not completed.
  #
  # Aborting a sis batch that is running can take some time for every process to
  # see the abort event. Subsequent sis batches begin to process 10 minutes
  # after the abort to allow each process to clean up properly.
  #
  # @example_request
  #   curl https://<canvas>/api/v1/accounts/<account_id>/sis_imports/<sis_import_id>/abort \
  #     -H 'Authorization: Bearer <token>'
  #
  # @returns SisImport
  def abort
    if authorized_action(@account, @current_user, [:import_sis, :manage_sis])
      SisBatch.transaction do
        @batch = @account.sis_batches.not_completed.lock.find(params[:id])
        @batch.abort_batch
      end
      render json: sis_import_json(@batch.reload, @current_user, session, includes: ["errors"])
    end
  end

  # @API Abort all pending SIS imports
  #
  # Abort already created but not processed or processing SIS imports.
  #
  # @example_request
  #   curl https://<canvas>/api/v1/accounts/<account_id>/sis_imports/abort_all_pending \
  #     -H 'Authorization: Bearer <token>'
  #
  # @returns boolean
  def abort_all_pending
    if authorized_action(@account, @current_user, [:import_sis, :manage_sis])
      SisBatch.abort_all_pending_for_account(@account)
      render json: { aborted: true }
    end
  end
end
