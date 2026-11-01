# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Gamerom::Repo, '#update_database' do
  let(:repo) { described_class.new('vimm') }

  let(:cache_dir) { Dir.mktmpdir }

  before { stub_const('Gamerom::CACHE_DIR', cache_dir) }
  after { FileUtils.rm_rf(cache_dir) }

  it 'refuses to overwrite a populated database with an empty crawl' do
    FileUtils.mkdir_p("#{Gamerom::CACHE_DIR}/vimm")
    File.write("#{Gamerom::CACHE_DIR}/vimm/N64.yml", [{ id: 1, name: 'Game', region: 'USA' }].to_yaml)
    allow(Gamerom::RepoAdapters::Vimm).to receive(:games).and_return([])

    expect { repo.update_database('N64') }.to raise_error(Gamerom::Error, /keeping the existing database/)
    expect(YAML.load_file("#{Gamerom::CACHE_DIR}/vimm/N64.yml").size).to eq(1)
  end

  it 'writes an empty database when there was none before' do
    allow(Gamerom::RepoAdapters::Vimm).to receive(:games).and_return([])

    repo.update_database('N64')
    expect(YAML.load_file("#{Gamerom::CACHE_DIR}/vimm/N64.yml")).to eq([])
  end
end
