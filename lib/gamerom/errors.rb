# frozen_string_literal: true

module Gamerom
  class Error < StandardError; end

  # Raised by repo adapters whose site does not allow automated downloads.
  # The message tells the user where to download the game and where to save it.
  class ManualDownloadRequired < Error; end
end
