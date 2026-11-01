# frozen_string_literal: true

RSpec.describe Gamerom::Cli do
  let(:cli) { described_class.new }
  let(:repo) { Gamerom::Repo.new('vimm') }
  let(:games) do
    {
      2748 => 'South Park',
      2749 => "South Park: Chef's Luv Shack",
      2750 => 'South Park Rally',
      546 => 'Mega Man 2',
      88_336 => 'Mega Man 2 (Capcom Town)',
      1303 => 'Jeopardy!',
      1304 => 'Jeopardy! Deluxe Edition',
      2637 => 'Legend of Zelda, The: Ocarina of Time',
      40_603 => 'Legend of Zelda, The: Ocarina of Time (GameCube)'
    }
  end
  let(:parsed_names) { games.transform_values { |name| cli.send(:parse_rom_name, name) } }

  def game(id)
    Gamerom::Game.new(id: id, name: games[id], platform: 'N64', region: 'USA', repo: repo)
  end

  def belongs?(file, id)
    cli.send(:file_belongs_to_game?, file, game(id), parsed_names)
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

    it 'gives a tagged re-release to the game whose name carries the tag' do
      expect(belongs?('Mega_Man_2_(USA)_(Capcom_Town).zip', 88_336)).to be true
    end

    it 'keeps a tagged re-release away from the plain game' do
      expect(belongs?('Mega_Man_2_(USA)_(Capcom_Town).zip', 546)).to be false
    end

    it 'keeps the plain file with the plain game' do
      expect(belongs?('Mega_Man_2_(USA).zip', 546)).to be true
    end

    it 'does not give the plain file to the tagged game' do
      expect(belongs?('Mega_Man_2_(USA).zip', 88_336)).to be false
    end

    it 'ignores punctuation differences between title and file name' do
      expect(belongs?('Legend_of_Zelda,_The_-_Ocarina_of_Time_(USA).zip', 2637)).to be true
    end

    it 'handles double extensions' do
      expect(belongs?('Legend_of_Zelda,_The_-_Ocarina_of_Time_(USA)_(GameCube).nkit.iso', 40_603)).to be true
    end

    it 'does not let a title with a bang swallow its editions' do
      expect(belongs?('Jeopardy!_-_Deluxe_Edition_(USA).zip', 1303)).to be false
    end

    it 'keeps multi-disc files together' do
      expect(belongs?('South_Park_(USA)_(Disc_2).zip', 2748)).to be true
    end
  end
end
