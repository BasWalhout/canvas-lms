# frozen_string_literal: true

#
# Copyright (C) 2023 - present Instructure, Inc.
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

class Mutations::UpdateRubricArchivedState < Mutations::BaseMutation
  argument :archived, Boolean, required: true
  argument :id, ID, required: true

  field :rubric, Types::RubricType, null: true
  def resolve(input:)
    begin
      @rubric = Rubric.find(input[:id])
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Rubric not found: #{input[:id]}"
    end
    requested_permission = input[:archived] ? :archive : :unarchive
    verify_authorized_action!(@rubric, requested_permission)
    if input[:archived]
      @rubric.archive
    else
      @rubric.unarchive
    end
    { rubric: @rubric }
  end
end
