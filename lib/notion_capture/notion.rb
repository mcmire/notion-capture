require_relative 'notion/authenticator'
require_relative 'notion/client'
require_relative 'notion/requestor'

module NotionCapture
  module Notion
    USER_ID = ENV.fetch('NOTION_USER_ID')
    TOKEN_FILE = NotionCapture::ROOT.join('tmp/.notion-token')
  end
end
