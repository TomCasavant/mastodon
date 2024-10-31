# frozen_string_literal: true

module WellKnown
  class AtprotoDidController < ActionController::Base # rubocop:disable Rails/ApplicationController
    include RoutingHelper

    before_action :set_account
    before_action :check_account_suspension

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request

    def show
      expires_in 3.days, public: true
      render plain: @account.atproto_did, content_type: 'text/plain'
    end

    private

    def set_account
      username = username_from_resource

      @account = begin
        if username == Rails.configuration.x.local_domain || username == Rails.configuration.x.web_domain
          Account.representative
        else
          Account.find_local!(username)
        end
      rescue ActiveRecord::RecordNotFound
        not_found
      end

      if @account.atproto_did.nil? || @account.atproto_did.empty?
        not_found
      end
    end

    def username_from_resource
      resource_user = request.subdomain  # Use subdomain if resource_param is nil
      username, *domain_parts = resource_user.split('.')
      domain = request.domain

      if Rails.configuration.x.alternate_domains.include?(domain)
        resource_user = "#{username}@#{Rails.configuration.x.local_domain}"
      else
        resource_user = "#{username}@#{domain}"
      end

      WebfingerResource.new(resource_user).username
    end

    def check_account_suspension
      if @account.permanently_unavailable?
        gone
      end
    end

    def gone
      expires_in(3.minutes, public: true)
      head 410
    end

    def bad_request
      expires_in(3.minutes, public: true)
      head 400
    end

    def not_found
      expires_in(3.minutes, public: true)
      head 404
    end
  end
end
