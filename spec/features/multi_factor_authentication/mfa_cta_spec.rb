require 'rails_helper'

feature 'mfa cta banner' do
  include DocAuthHelper
  include SamlAuthHelper
  
  context 'multiple factor authentication feature is disabled' do
    it 'does not display a banner' do
      visit_idp_from_sp_with_ial1(:oidc)
      user = sign_up_and_set_password
      select_2fa_option('backup_code')
      click_continue

      expect(MfaPolicy.new(user).multiple_factors_enabled?).to eq false
      expect(page).to have_current_path(sign_up_completed_path)
      expect(page).not_to have_content(t('mfa.second_method_warning.text'))
    end
  end

  context 'multiple factor authentication feature is enabled' do
    before do
      allow(IdentityConfig.store).to receive(:select_multiple_mfa_options).and_return(true)
    end

    it 'displays a banner' do
      visit_idp_from_sp_with_ial1(:oidc)
      user = sign_up_and_set_password
      select_2fa_option('backup_code')
      click_continue

      expect(page).to have_current_path(sign_up_completed_path)
      expect(MfaPolicy.new(user).multiple_factors_enabled?).to eq false
      expect(page).to have_content(t('mfa.second_method_warning.text'))
    end

    it 'redirects user to choose multiple methods of authentication when banner is displayed' do
      visit_idp_from_sp_with_ial1(:oidc)
      user = sign_up_and_set_password
      select_2fa_option('backup_code')
      click_continue
      expect(page).to have_current_path(sign_up_completed_path)
      click_on(t('mfa.second_method_warning.link'))

      expect(response).to redirect_to two_factor_options_url(mfa_selected: false)
    end

    it 'does not display a banner' do
      visit_idp_from_sp_with_ial1(:oidc)
      user = sign_up_and_set_password
      select_2fa_option('backup_code')
      click_continue
    end
  end  
end
