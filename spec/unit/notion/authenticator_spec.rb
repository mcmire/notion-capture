RSpec.describe NotionCapture::Notion::Authenticator do
  let(:token_file) do
    Pathname
      .new('../../tmp/test-notion-token')
      .expand_path(__dir__)
      .tap { |path| path.parent.mkpath }
  end

  describe '#authenticate' do
    context 'if the token file exists' do
      context 'if the token file has content' do
        it 'returns the content' do
          token_file.write('foo')
          authenticator = described_class.new(token_file)
          allow(authenticator).to receive(:reauthenticate).and_return(
            "this shouldn't be called",
          )

          token = authenticator.authenticate

          expect(token).to eq('foo')
        end
      end

      context 'if the token file does not have content' do
        it 'returns the value of #reauthenticate' do
          FileUtils.touch(token_file)
          authenticator = described_class.new(token_file)
          allow(authenticator).to receive(:reauthenticate).and_return('foo')

          token = authenticator.authenticate

          expect(token).to eq('foo')
        end
      end
    end

    context 'if the token file does not exist' do
      it 'returns the value of #reauthenticate' do
        authenticator = described_class.new(token_file)
        allow(authenticator).to receive(:reauthenticate).and_return('foo')

        token = authenticator.authenticate

        expect(token).to eq('foo')
      end
    end
  end

  describe '#reauthenticate' do
    it 'logs in to Notion, captures the token from the cookies, and writes it to file' do
      authenticator = described_class.new(token_file)

      token = authenticator.reauthenticate

      expect(token).to be
      expect(token_file.read.strip).to eq(token)
    end
  end
end
