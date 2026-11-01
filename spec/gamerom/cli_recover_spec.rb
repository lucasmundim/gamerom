# frozen_string_literal: true

RSpec.describe Gamerom::Cli do
  let(:cli) { described_class.new }
  let(:repo) { Gamerom::Repo.new('vimm') }
  let(:games) do
    {
      2748 => 'South Park',
      2749 => "South Park: Chef's Luv Shack",
      2750 => 'South Park Rally',
      2744 => 'Shadow Man'
    }
  end

  def game(id)
    Gamerom::Game.new(id: id, name: games[id], platform: 'N64', region: 'USA', repo: repo)
  end

  def belongs?(file, id)
    cli.send(:file_belongs_to_game?, file, game(id), games)
  end

  describe '#file_belongs_to_game?' do
    it 'keeps the exact file for the shorter name' do
      expect(belongs?('South_Park_(USA).zip', 2748)).to be true
    end

    it 'leaves a file named after a longer title with a colon to that game' do
      expect(belongs?("South_Park_-_Chef's_Luv_Shack_(USA).zip", 2748)).to be false
    end

    it 'leaves a file named after a longer title to that game' do
      expect(belongs?('South_Park_Rally_(USA).zip', 2748)).to be false
    end

    it 'lets the longer title keep its own file' do
      expect(belongs?("South_Park_-_Chef's_Luv_Shack_(USA).zip", 2749)).to be true
    end
  end
end
