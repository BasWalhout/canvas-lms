# frozen_string_literal: true

#
# Copyright (C) 2017 - present Instructure, Inc.
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

describe PlannerOverridesController do
  before :once do
    course_with_teacher(active_all: true)
    student_in_course(active_all: true)
    @group = @course.assignment_groups.create(name: "some group")
    @assignment = course_assignment
    @assignment2 = course_assignment
    @planner_override = PlannerOverride.create!(plannable_id: @assignment.id,
                                                plannable_type: "Assignment",
                                                marked_complete: false,
                                                user_id: @student.id)
  end

  def course_assignment
    @course.assignments.create(
      title: "some assignment #{@course.assignments.count}",
      assignment_group: @group,
      due_at: 1.week.from_now
    )
  end

  context "unauthenticated" do
    it "returns unauthorized" do
      get :index
      assert_unauthorized

      post :create, params: { plannable_type: "assignment",
                              plannable_id: @assignment.id,
                              marked_complete: false }
      assert_unauthorized
    end
  end

  context "as student" do
    before do
      user_session(@student)
    end

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to be_successful
      end
    end

    describe "GET #show" do
      it "returns http success" do
        get :show, params: { id: @planner_override.id }
        expect(response).to be_successful
      end
    end

    describe "PUT #update" do
      it "returns http success" do
        expect(@planner_override.marked_complete).to be_falsey
        put :update, params: { id: @planner_override.id, marked_complete: true, dismissed: true }
        expect(response).to be_successful
        expect(@planner_override.reload.marked_complete).to be_truthy
        expect(@planner_override.dismissed).to be_truthy
      end

      it "invalidates the planner cache" do
        expect(Rails.cache).to receive(:delete).with(/#{controller.planner_meta_cache_key}/)
        put :update, params: { id: @planner_override.id, marked_complete: true, dismissed: true }
      end
    end

    describe "POST #create" do
      it "returns http success" do
        post :create, params: { plannable_type: "assignment", plannable_id: @assignment2.id, marked_complete: true }
        expect(response).to have_http_status(:created)
        expect(PlannerOverride.where(user_id: @student.id).count).to be 2
      end

      it "invalidates the planner cache" do
        expect(Rails.cache).to receive(:delete).with(/#{controller.planner_meta_cache_key}/)
        post :create, params: { plannable_type: "assignment", plannable_id: @assignment2.id, marked_complete: true }
      end

      it "saves announcement overrides with a plannable_type of announcement" do
        announcement_model(context: @course)
        post :create, params: { plannable_type: "announcement", plannable_id: @a.id, user_id: @student.id, marked_complete: true }
        json = json_parse(response.body)
        expect(json["plannable_type"]).to eq "announcement"
      end

      it "gracefully handles duplicate request race condition" do
        ovr = PlannerOverride.new
        allow(PlannerOverride).to receive(:new).and_return(ovr)
        expect(ovr).to receive(:save) do
          raise ActiveRecord::RecordNotUnique, "PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint..."
        end
        post :create, params: { plannable_type: "assignment", plannable_id: @assignment2.id, marked_complete: true }
        expect(response).to have_http_status(:bad_request)
        expect(PlannerOverride.where(user_id: @student.id).count).to be 1
      end

      it "saves sub_assignment overrides with plannable type sub_assignment" do
        @course.account.enable_feature!(:discussion_checkpoints)
        @reply_to_topic, @reply_to_entry = graded_discussion_topic_with_checkpoints(context: @course)
        post :create, params: { plannable_type: "sub_assignment", plannable_id: @reply_to_topic.id, user_id: @student.id, marked_complete: true }
        json = json_parse(response.body)
        expect(json["plannable_type"]).to eq "sub_assignment"
        post :create, params: { plannable_type: "sub_assignment", plannable_id: @reply_to_entry.id, user_id: @student.id, marked_complete: true }
        json = json_parse(response.body)
        expect(json["plannable_type"]).to eq "sub_assignment"
      end
    end

    describe "DELETE #destroy" do
      it "returns http success" do
        delete :destroy, params: { id: @planner_override.id }
        expect(response).to be_successful
        expect(@planner_override.reload).to be_deleted
      end

      it "invalidates the planner cache" do
        expect(Rails.cache).to receive(:delete).with(/#{controller.planner_meta_cache_key}/)
        delete :destroy, params: { id: @planner_override.id }
      end
    end
  end
end
