require 'open3'

class Array
  def intersperse(separator)
    (inject([]) { |a, v| a + [v, separator] })[0...-1]
  end
end

module VersionsHelper
  def body_html
    return body unless @module

    frag = Nokogiri::HTML(body)
    7.downto(1).each do |index|
      frag.xpath("//h#{index}").each { |div| div.name = "h#{index + 1}" }
    end
    frag.css('pre code:not([class])').each { |code| code['class'] = 'elm' }
    frag.to_html
  end

  def body
    return GitHub::Markup.render('readme.md', @version.readme) unless @module

    mod =
      @version
      .documentation
      .find { |item| item['name'] == @module }
      .to_h

    mod['comment']
      .split(/(\@docs\s+.*)/)
      .map do |match|
        if match =~ /\@docs\s+(.*)/
          $1.split(',')
            .map(&:strip)
            .map do |item|
              value(mod, item) || alias_(mod, item) || type(mod, item)
            end
            .intersperse('<div class="version-detail__separator"></div>')
        else
          GitHub::Markup.render('readme.md', match)
        end
      end
      .flatten
      .join('')
  end

  def value(mod, item)
    infix =
      item.match(/^\(/)

    normalized =
      item
      .gsub(/^\(/, '')
      .gsub(/\)$/, '')

    x = mod['values']
        .find { |val| val['name'] == normalized }
        .to_h
        .symbolize_keys

    return nil if x.empty?

    name =
      if infix
        "(#{x[:name]})"
      else
        x[:name]
      end

    x[:code] =
      "#{name} : #{x[:type]}"

    render partial: 'value', locals: x
  end

  def alias_(mod, item)
    x = mod['aliases']
        .find { |val| val['name'] == item }
        .to_h
        .symbolize_keys

    return nil if x.empty?

    first =
      "type alias #{x[:name]} #{x[:args].join(' ')}".strip

    x[:code] =
      "#{first} =\n#{x[:type].gsub(/[,|]/, "\n\\0").gsub(/\}$/, "\n}")}\n"

    render partial: 'alias', locals: x
  end

  def type(mod, item)
    x = mod['types']
        .find { |val| val['name'] == item }
        .to_h
        .symbolize_keys

    return nil if x.empty?

    x[:code] =
      if x[:cases].empty?
        "type #{x[:name]} #{x[:args].join(' ')}".strip
      else
        cases =
          x[:cases].map do |(a, b)|
            if b.empty?
              a
            elsif b.length == 1
              params = b[0] =~ /\s/ ? "(#{b[0]})" : b[0]
              "#{a} #{params}"
            else
              params = b.map { |p| p =~ /\s/ ? "(#{p})" : p }.join(' ')
              "#{a} #{params}"
            end
          end

        first =
          "type #{x[:name]} #{x[:args].join(' ')}".strip

        "#{first}\n= #{cases.join("\n| ")}"
      end

    render partial: 'type', locals: x
  end
end
