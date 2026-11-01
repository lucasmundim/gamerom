# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Gamerom::Repo do
  describe '#update_database' do
    let(:repo) { described_class.new('vimm') }
    let(:cache_dir) { Dir.mktmpdir }
    let(:database) { "#{cache_dir}/vimm/N64.yml" }

    before do
      stub_const('Gamerom::CACHE_DIR', cache_dir)
      allow(Gamerom::RepoAdapters::Vimm).to receive(:games).and_return([])
    end

    after { FileUtils.rm_rf(cache_dir) }

    context 'when the crawl finds no games but a populated database exists' do
      before do
        FileUtils.mkdir_p(File.dirname(database))
        File.write(database, [{ id: 1, name: 'Game', region: 'USA' }].to_yaml)
      end

      it 'raises instead of overwriting it' do
        expect { repo.update_database('N64') }.to raise_error(Gamerom::Error, /keeping the existing database/)
      end

      it 'keeps the existing games', :aggregate_failures do
        expect { repo.update_database('N64') }.to raise_error(Gamerom::Error)
        expect(YAML.load_file(database).size).to eq(1)
      end
    end

    it 'writes an empty database when there was none before' do
      repo.update_database('N64')
      expect(YAML.load_file(database)).to eq([])
    end
  end
end
