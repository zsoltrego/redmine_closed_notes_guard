# frozen_string_literal: true
require_dependency 'issues_controller'

module RedmineClosedNotesGuard
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do
          alias_method :update_without_rcng, :update
          alias_method :update, :update_with_rcng
        end
      end

      def update_with_rcng
        issue = Issue.find(params[:id])

        if issue.closed? && params.dig(:issue, :notes).present?
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
                # az edit.js / form update kérésekre ne rendereljünk HTML-t
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

unless IssuesController.included_modules.include?(RedmineClosedNotesGuard::Patches::IssuesControllerPatch)
  IssuesController.include RedmineClosedNotesGuard::Patches::IssuesControllerPatch
end
