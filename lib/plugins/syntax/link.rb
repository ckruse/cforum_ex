# -*- coding: utf-8 -*-

require 'uri'

ParserHelper.parser_modules['url'] = {
  type: :after_parsing,
  html: Proc.new do |tag_name, arg, content, html|
    if args.empty? and content.empty?
      html << '[url][/url]'
    else
      title = content
      url   = if args.empty?
                content
              else
                args[0]
              end

      begin
        u = URI.parse(url)
        html << '<a href="' + encode_entities(url.strip) + '">' + encode_entities(title.strip) + '</a>'
      rescue
        if args.empty?
          html << "[url]" + encode_entities(content.strip) + "[/url]"
        else
          html << "[url=" + encode_entities(args[0].strip) + "]" + encode_entities(content.strip) + "[/url]"
        end
      end

    end
  end,

  txt: Proc.new do |tag_name, args, content, txt|
    if args.empty?
      txt << '[url]' + content.strip + '[/url]'
    else
      txt << '[url=' + args[0].strip + ']' + content.strip + '[/url]'
    end
  end
}

# eof
