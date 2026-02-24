# frozen_string_literal: true
require_dependency 'journals_controller'

module RedmineClosedNotesGuard
  module Patches
    module JournalsControllerPatch
      def self.included(base)
        base.class_eval do
          alias_method :update_without_rcng, :update
          alias_method :update, :update_with_rcng
        end
      end

      def update_with_rcng
        journal = Journal.find(params[:id])
        issue = journal.journalized.is_a?(Issue) ? journal.journalized : nil

        if issue&.closed? && params.dig(:journal, :notes).present?
          plugin_settings = Setting.plugin_redmine_closed_notes_guard || {}
          blocked_ids = Array(plugin_settings['blocked_role_ids']).reject(&:blank?).map(&:to_i)
          user_role_ids = User.current.roles_for_project(issue.project).map(&:id)

          if blocked_ids.any? && (user_role_ids & blocked_ids).any?
            msg = l(:rcng_error_closed_issue_notes_forbidden)

            respond_to do |format|
              format.html do
                flash[:error] = msg
                return redirect_to(issue_path(issue))
              end
              format.js do
                return render plain: msg, status: 403
              end
              format.any do
                return head :forbidden
              end
            end
          end
        end

        update_without_rcng
      end
    end
  end
end

unless JournalsController.included_modules.include?(RedmineClosedNotesGuard::Patches::JournalsControllerPatch)
  JournalsController.include RedmineClosedNotesGuard::Patches::JournalsControllerPatch
end
