require 'rails_helper'

describe SignUp::EmailConfirmationsController do
  describe '#create' do
    before do
      stub_analytics
    end

    it 'tracks nil email confirmation token' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: nil }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks blank email confirmation token' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: '' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks confirmation token as a single-quoted empty string' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: "''" }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks confirmation token as a double-quoted empty string' do
      analytics_hash = {
        success: false,
        error_details: { confirmation_token: [:not_found] },
        errors: { confirmation_token: ['not found'] },
        user_id: nil,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: '""' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_invalid_token')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks already confirmed token' do
      email_address = create(:email_address, confirmation_token: 'foo')

      analytics_hash = {
        success: false,
        errors: { email: [t('errors.messages.already_confirmed')] },
        error_details: nil,
        user_id: email_address.user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: 'foo' }
    end

    it 'tracks expired token' do
      invalid_confirmation_sent_at =
        Time.zone.now - (IdentityConfig.store.add_email_link_valid_for_hours.hours.to_i + 1)
      email_address = create(
        :email_address,
        :unconfirmed,
        confirmation_token: 'foo',
        confirmation_sent_at: invalid_confirmation_sent_at,
        user: build(:user, email: nil),
      )

      analytics_hash = {
        success: false,
        errors: { confirmation_token: [t('errors.messages.expired')] },
        error_details: { confirmation_token: [:expired] },
        user_id: email_address.user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: 'foo' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_period_expired')
      expect(response).to redirect_to sign_up_email_resend_path
    end

    it 'tracks blank confirmation_sent_at as expired token' do
      email_address = create(
        :email_address,
        :unconfirmed,
        confirmation_token: 'foo',
        confirmation_sent_at: nil,
        user: build(:user, email: nil),
      )
      user = email_address.user

      analytics_hash = {
        success: false,
        errors: { confirmation_token: [t('errors.messages.expired')] },
        error_details: { confirmation_token: [:expired] },
        user_id: user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: 'foo' }

      expect(flash[:error]).to eq t('errors.messages.confirmation_period_expired')
      expect(response).to redirect_to sign_up_email_resend_path
    end
  end

  describe 'Valid email confirmation tokens' do
    it 'tracks a valid email confirmation token event' do
      email_address = create(
        :email_address,
        :unconfirmed,
        confirmation_token: 'foo',
        user: build(:user, email: nil),
      )
      user = email_address.user

      stub_analytics

      analytics_hash = {
        success: true,
        errors: {},
        error_details: nil,
        user_id: user.uuid,
      }

      expect(@analytics).to receive(:track_event).
        with('User Registration: Email Confirmation', analytics_hash)

      get :create, params: { confirmation_token: 'foo' }
    end
  end

  describe 'Two users simultaneously confirm email with race condition' do
    it 'does not throw a 500 error' do
      create(
        :email_address,
        :unconfirmed,
        confirmation_token: 'foo',
        user: build(:user, email: nil),
      )

      allow(subject).to receive(:process_successful_confirmation).
        and_raise(ActiveRecord::RecordNotUnique)

      get :create, params: { confirmation_token: 'foo' }

      expect(flash[:error]).
        to eq t(
          'devise.confirmations.already_confirmed',
          action: t('devise.confirmations.sign_in'),
        )
      expect(response).to redirect_to root_url
    end
  end
end
