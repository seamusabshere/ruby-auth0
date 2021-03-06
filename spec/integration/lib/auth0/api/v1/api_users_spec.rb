require "spec_helper"
describe Auth0::Api::V1::Users do

  let(:client) { Auth0Client.new(v1_creds) }
  let(:username) { Faker::Internet.user_name }
  let(:email) { Faker::Internet.safe_email("#{username}#{entity_suffix}") }
  let(:password) { Faker::Internet.password }
  let(:connection) { "Username-Password-Authentication" }
  let!(:user) { client.create_user(email, password, connection, {
    "username" => username,
    "email_verified" => false,
  })}

  describe '.users' do

    let(:users) { client.users() }

    it { expect(users.size).to be > 0 }
    it { expect(users.find {|user| user["email"] == email}).to_not be_nil }

    context "#filters" do
      it { expect(client.users("email: #{email}").size).to be 1 }
    end

  end

  describe '.user' do

    let(:subject) { client.user(user["user_id"]) }

    it { should include("email" => email, "username" => username) }

  end

  describe '.create_user' do

    let(:subject) { user }

    it { should include("user_id", "identities") }
    it { should include(      
      "username" => username,
      "email" => email,
      "email_verified" => false,
    )}

  end

  describe '.delete_user' do

    it { expect { client.delete_user user["user_id"] }.to_not raise_error }

    it { expect { client.delete_user "" }.to raise_error(Auth0::MissingUserId) }

  end

  describe '.patch_user_metadata' do
    it { expect(client.patch_user_metadata(user["user_id"], {"custom_field" => "custom_value"})).to eq "OK" }
  end

end
