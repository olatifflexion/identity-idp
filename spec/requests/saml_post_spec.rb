require 'rails_helper'

RSpec.describe 'SAML POST handling', type: :request do
  describe 'POST /api/saml/auth' do
    let(:cookie_regex) { /\A(?<cookie>\w+)=/ }

    it 'does not set a session cookie' do
      post send("api_saml_auth#{Time.zone.today.year}_url")
      new_cookies = response.header['Set-Cookie'].split("\n").map do |c|
        cookie_regex.match(c)[:cookie]
      end
      expect(new_cookies).not_to include('_upaya_session')
    end
  end
end
