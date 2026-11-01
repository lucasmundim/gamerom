# frozen_string_literal: true

RSpec.describe Gamerom::RepoAdapters::Vimm do
  describe '.install' do
    let(:game) { Gamerom::Game.new(id: 545, name: 'Mega Man', platform: 'NES', region: 'USA', repo: Gamerom::Repo.new('vimm')) }

    before { allow(FileUtils).to receive(:mkdir_p) }

    it 'asks the user to download the game manually from the game page' do
      expect { described_class.install(game) }.to raise_error(Gamerom::ManualDownloadRequired, %r{https://vimm.net/vault/545})
    end

    it 'tells the user where to save the file and how to register it' do
      expect { described_class.install(game) }
        .to raise_error(Gamerom::ManualDownloadRequired, /#{Regexp.escape(game.filepath)}.*recover -r vimm -p NES/m)
    end

    it 'prepares the target directory' do
      described_class.install(game)
    rescue Gamerom::ManualDownloadRequired
      expect(FileUtils).to have_received(:mkdir_p).with(game.filepath)
    end
  end
end
