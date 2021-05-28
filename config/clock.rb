require 'clockwork'
require_relative 'lib/notion_capture'

DAY = 60 * 60 * 24

Clockwork.every(DAY, 'notion.capture') { NotionCapture.run }
