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

RSpec.describe Gamerom::RepoAdapters::Vimm, '.extract_games' do
  let(:page) do
    Nokogiri::HTML(<<~HTML)
      <table class="rounded centered cellpadding1 hovertable striped">
        <caption><table class="cellpadding1"><tr><th>Title</th><th>Region</th><th>Rating</th></tr></table></caption>
        <tr>
          <td><img src="/images/icons/cart.svg" class="media-icon"><a href="/vault/2640" onmouseover="buildTooltip(this, 2640, 320, 240)">Mace: The Dark Age</a></td>
          <td><img src="/images/flags/usa.png" class="flag" title="USA"></td>
          <td><a href="/vault/?p=rating&amp;id=2640">8.1</a></td>
        </tr>
        <tr>
          <td><img src="/images/icons/cart.svg" class="media-icon"><a href="/vault/2641" onmouseover="buildTooltip(this, 2641, 320, 240)">Madden Football 64</a></td>
          <td></td><td></td>
        </tr>
      </table>
    HTML
  end

  before do
    allow(described_class).to receive(:sections).and_return(['m'])
    allow(described_class).to receive(:nokogiri_get).and_return(page)
  end

  it 'extracts one game per row, ignoring the rating links' do
    games = []
    described_class.extract_games('N64') { |section_games, _index| games.concat(section_games) }
    expect(games).to eq([
      { id: 2640, name: 'Mace: The Dark Age', region: 'USA' },
      { id: 2641, name: 'Madden Football 64', region: 'USA' },
    ])
  end
end
