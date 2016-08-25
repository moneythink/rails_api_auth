shared_examples 'a authenticator' do
  describe '#authenticate!' do
    let(:login) { double('login') }
    client = Oauth2Controller::DEFAULT_CLIENT_NAME

    if described_class::PROVIDER.eql? 'edx'
      subject { described_class.new(username, auth_code, client).authenticate! }
    else
      subject { described_class.new(auth_code, client).authenticate! }
    end

    context "when no login for the #{described_class::PROVIDER} account exists" do
      let(:login_attributes) do
        {
          provider: described_class::PROVIDER,
          client: client,
          identification: authenticated_user_data[:email],
          uid: authenticated_user_data[uid_mapped_field.to_sym]
        }
      end

      before do
        allow(Login).to receive(:create!).with(login_attributes).and_return(login)
      end

      it "returns a login created from the #{described_class::PROVIDER} account" do
        expect(subject).to eql(login)
      end
    end

    context "when an old login for the #{described_class::PROVIDER} account exists already" do
      before do
        # an "old" login doesn't have a provider or client
        expect(Login).to receive(:where).with(
            provider: described_class::PROVIDER,
            client: client,
            identification: authenticated_user_data[:email]
          ).and_return([])
          expect(Login).to receive(:where).with(
              provider: nil,
              client: nil,
              identification: authenticated_user_data[:email]
            ).and_return([login])
        allow(login).to receive(:update_attributes!).with(uid: authenticated_user_data[uid_mapped_field.to_sym], provider: described_class::PROVIDER, client: client)
      end

      it "connects the login to the #{described_class::PROVIDER} account" do
        expect(login).to receive(:update_attributes!).with(uid: authenticated_user_data[uid_mapped_field.to_sym], provider: described_class::PROVIDER, client: client)

        subject
      end
    end

    context "when a new login for the #{described_class::PROVIDER} account exists already" do
      before do
        expect(Login).to receive(:where).with(
            provider: described_class::PROVIDER,
            client: client,
            identification: authenticated_user_data[:email]
          ).and_return([login])
        allow(login).to receive(:update_attributes!).with(uid: authenticated_user_data[uid_mapped_field.to_sym], provider: described_class::PROVIDER, client: client)
      end

      it "connects the login to the #{described_class::PROVIDER} account" do
        expect(login).to receive(:update_attributes!).with(uid: authenticated_user_data[uid_mapped_field.to_sym], provider: described_class::PROVIDER, client: client)

        subject
      end
    end
  end
end
