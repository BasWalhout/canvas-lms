# frozen_string_literal: true

#
# Copyright (C) 2021 - present Instructure, Inc.
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

describe Importers::LtiResourceLinkImporter do
  subject { described_class.process_migration(hash, migration) }

  let!(:source_course) { course_model }
  let!(:destination_course) { course_model }
  let!(:migration) { ContentMigration.create(context: destination_course, source_course:) }

  let_once(:registration) { lti_registration_with_tool(account: destination_course.root_account, created_by: user_model) }
  let_once(:tool) { registration.deployments.first }

  context "when `lti_resource_links` is not given" do
    let(:hash) { { lti_resource_links: nil } }

    it "does not import lti resource links" do
      expect(subject).to be false
    end
  end

  context "when `lti_resource_links` is given" do
    let(:custom_params) do
      { "param1" => "value1 " }
    end
    let(:lookup_uuid) { "1b302c1e-c0a2-42dc-88b6-c029699a7c7a" }
    let(:hash) do
      {
        "lti_resource_links" => [
          {
            "custom" => custom_params,
            "lookup_uuid" => lookup_uuid,
            "launch_url" => tool.url
          }
        ]
      }
    end

    context "when the Lti::ResourceLink.context_type is an Assignment" do
      let!(:assignment) do
        destination_course.assignments.create!(
          submission_types: "external_tool",
          external_tool_tag_attributes: { content: tool },
          points_possible: 10
        )
      end
      let!(:resource_link) do
        Lti::ResourceLink.create!(
          context_external_tool: tool,
          context: assignment,
          lookup_uuid:,
          custom: nil,
          url: "http://www.example.com/launch"
        )
      end

      context "when the associated assignment is selected for import" do
        it "update the custom params" do
          expect(resource_link.custom).to be_nil

          expect(subject).to be true

          resource_link.reload

          expect(resource_link.custom).to eq custom_params
        end
      end

      context "when the associated assignment is not selected for import" do
        before do
          allow(Importers::LtiResourceLinkImporter).to receive(:filter_by_assignment_context).and_return([])
        end

        it "does not import lti resource links" do
          expect(subject).to be false
        end
      end
    end

    context "when the Lti::ResourceLink.context_type is a Course" do
      context "and the resource link was not recorded" do
        it "create the new resource link" do
          expect(subject).to be true

          expect(destination_course.lti_resource_links.size).to eq 1
          expect(destination_course.lti_resource_links.first.lookup_uuid).to eq lookup_uuid
          expect(destination_course.lti_resource_links.first.custom).to eq custom_params
        end
      end

      context "and the resource link was recorded" do
        before do
          destination_course.lti_resource_links.create!(
            context_external_tool: tool,
            custom: nil,
            lookup_uuid:
          )
        end

        it "update the custom params" do
          expect(subject).to be true

          expect(destination_course.lti_resource_links.size).to eq 1
          expect(destination_course.lti_resource_links.first.lookup_uuid).to eq lookup_uuid
          expect(destination_course.lti_resource_links.first.custom).to eq custom_params
        end
      end
    end
  end

  describe "filter_by_assignment_context" do
    subject { Importers::LtiResourceLinkImporter }

    let!(:migration) { Struct.new(:import_object?).new }
    let!(:lookup_uuid) { "1b302c1e-c0a2-42dc-88b6-c029699a7c7a" }
    let!(:assignments) do
      [
        {
          "resource_link_lookup_uuid" => lookup_uuid
        }
      ]
    end

    context "when lti_resource_link has an associated assignemnt context" do
      let!(:lti_resource_links) do
        [
          {
            "lookup_uuid" => lookup_uuid,
          }
        ]
      end

      context "when assignment selected for import" do
        before do
          allow(migration).to receive_messages(
            import_everything?: false,
            import_object?: true
          )
        end

        it "keeps the associated lti_resource_link" do
          filtered_lti_resource_links = subject.filter_by_assignment_context(lti_resource_links.dup, assignments, migration)
          expect(filtered_lti_resource_links).to include(lti_resource_links.first)
        end
      end

      context "when assignment does not selected for import" do
        before do
          allow(migration).to receive_messages(
            import_everything?: false,
            import_object?: false
          )
        end

        it "removes the associated lti_resource_link" do
          filtered_lti_resource_links = subject.filter_by_assignment_context(lti_resource_links.dup, assignments, migration)
          expect(filtered_lti_resource_links).not_to include(lti_resource_links.first)
        end
      end
    end

    context "when lti_resource_link does not have an associated assignemnt context" do
      let!(:lti_resource_links) do
        [
          {
            "lookup_uuid" => "11111111-2222-1111-2222-111111111111",
          }
        ]
      end

      context "when assignment selected for import" do
        before do
          allow(migration).to receive_messages(
            import_everything?: false,
            import_object?: true
          )
        end

        it "keeps the lti_resource_link" do
          filtered_lti_resource_links = subject.filter_by_assignment_context(lti_resource_links.dup, assignments, migration)
          expect(filtered_lti_resource_links).to include(lti_resource_links.first)
        end
      end

      context "when assignment does not selected for import" do
        before do
          allow(migration).to receive_messages(
            import_everything?: false,
            import_object?: false
          )
        end

        it "keeps the associated lti_resource_link" do
          filtered_lti_resource_links = subject.filter_by_assignment_context(lti_resource_links.dup, assignments, migration)
          expect(filtered_lti_resource_links).to include(lti_resource_links.first)
        end
      end
    end
  end
end
