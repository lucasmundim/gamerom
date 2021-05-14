# frozen_string_literal: true

RSpec.describe Gamerom::GameInfo do
  it "has a name" do
    name = "rom name"
    game_info = Gamerom::GameInfo.new(name)
    expect(game_info.name).to eq(name)
  end

  it "extracts region from name" do
    {
      '(1)' => 'Japan & Korea',
      '(4)' => 'USA & Brazil - NTSC',
      '(5)' => 'NTSC',
      '(8)' => 'PAL',
      '(A)' => 'Australia',
      '(As)' => 'Asia',
      '(B)' => 'Brazil',
      '(C)' => 'Canada',
      '(Ch)' => 'China',
      '(D)' => 'Netherlands (Dutch)',
      '(E)' => 'Europe',
      '(F)' => 'France',
      '(FC)' => 'French Canadian',
      '(FN)' => 'Finland',
      '(G)' => 'Germany',
      '(GR)' => 'Greece',
      '(H)' => 'Holland',
      '(HK)' => 'Hong Kong',
      '(I)' => 'Italy',
      '(J)' => 'Japan',
      '(JUE)' => 'Japan & USA & Europe',
      '(K)' => 'Korea',
      '(Nl)' => 'Netherlands',
      '(NL)' => 'Netherlands',
      '(No)' => 'Norway',
      '(PD)' => 'Public Domain',
      '(R)' => 'Russia',
      '(S)' => 'Spain',
      '(Sw)' => 'Sweden',
      '(SW)' => 'Sweden',
      '(U)' => "USA",
      '(UK)' => 'England',
      '(Unk)' => 'Unknown Country',
      '(Unl)' => 'Unlicensed',
      '(PAL)' => 'PAL regions (Australia, Europe)',
      '(NTSC)' => 'NTSC regions (Japan, USA, Latin America)',
      'Flag Capture (32-in-1) (Atari) (PAL) [!]' => 'PAL regions (Australia, Europe)',
    }.each do |name, expected_region|
      game_info = Gamerom::GameInfo.new(name)
      expect(game_info.region).to eq(expected_region)
    end
  end

  it "extracts tags from name" do
    {
      "[!]" => [:good],
      "[!p]" => [:pending],
      "[a]" => [:alternate],
      "[b]" => [:bad],
      "[BF]" => [:bung],
      "[c]" => [:checksum],
      "[C]" => [:color],
      "[f]" => [:fixed],
      "[h]" => [:hack],
      "[J]" => [:japanese_translation],
      "[o]" => [:overdump],
      "[p]" => [:pirate],
      "[PC10]" => [:pc10],
      "[S]" => [:super],
      "[T-]" => [:old_translation],
      "[t]" => [:trained],
      "[T+]" => [:newer_translation],
      "[VS]" => [:vs],
      "[x]" => [:bad_checksum],
      "[!][J][C]" => [:good, :japanese_translation, :color],
    }.each do |name, expected_tags|
      game_info = Gamerom::GameInfo.new(name)
      expect(game_info.tags).to eq(expected_tags)
    end
  end

end
