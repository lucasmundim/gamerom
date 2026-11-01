# frozen_string_literal: true

require 'nokogiri'

RSpec.describe Gamerom::RepoAdapters::Edgeemu do
  describe '.game' do
    let(:item) do
      Nokogiri::HTML(<<~HTML).at_css('details')
        <div class="item">
          <details data-name="3-D Genesis (USA) (Proto).zip">
            <summary>3-D Genesis (USA) (Proto)</summary>
              <p><a href="/download/atari-2600/3-D%20Genesis%20%28USA%29%20%28Proto%29.zip">download</a> (<span>5.53k, 68 DLs</span>)</p>
              <p>unpacked size: <span>8.00k</span></p>
              <p>hash:&nbsp;<span>931A0BDC</span></p>
          </details>
        </div>
      HTML
    end

    it 'uses the ROM crc32 as id' do
      expect(described_class.game(item)[:id]).to eq(0x931A0BDC)
    end

    it 'uses the file name without extension as name' do
      expect(described_class.game(item)[:name]).to eq('3-D Genesis (USA) (Proto)')
    end

    it 'extracts the region from the name' do
      expect(described_class.game(item)[:region]).to eq('USA')
    end

    it 'builds the absolute download url' do
      expect(described_class.game(item)[:url]).to eq('https://edgeemu.net/download/atari-2600/3-D%20Genesis%20%28USA%29%20%28Proto%29.zip')
    end
  end

  describe '.region' do
    it { expect(described_class.region('Espial (USA)')).to eq('USA') }
    it { expect(described_class.region('Game (USA, Europe) (Rev 1)')).to eq('USA') }
    it { expect(described_class.region('Game (Europe, USA)')).to eq('USA') }
    it { expect(described_class.region('Game (Japan, Europe)')).to eq('Japan') }
    it { expect(described_class.region('Game (Rev 1) (Japan)')).to eq('Japan') }
    it { expect(described_class.region('Game (Proto)')).to eq('Unknown') }
  end
end
