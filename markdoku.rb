require 'cgi'

def markup(src)
	tokens = {
		/\*\*(.+)\*\*/ => '<span style="font-weight:bold;">\1</span>',
		/\/\/(.+)\/\// => '<span style="font-style:italic;">\1</span>',
		/__(.+)__/ => '<span style="text-decoration:underline;">\1</span>',
		/\'\'(.+)\'\'/ => '<span style="font-family:monospace;">\1</span>',
		/<del>(.+)<\/del>/ => '<span style="text-decoration:line-through;">\1</span>',
		/\\\\\s/ => '<br />',
		/\(\((.+)\)\)\s/ => '<a href="#" class="tooltip"><sup>*)</sup><span style="display:none;">\1</span></a>',
		/\s([=]{6})(.+)\1/ => '<h1>\2</h1>',
		/\s([=]{5})(.+)\1/ => '<h2>\2</h2>',
		/\s([=]{4})(.+)\1/ => '<h3>\2</h3>',
		/\s([=]{3})(.+)\1/ => '<h4>\2</h4>',
		/\s([=]{2})(.+)\1/ => '<h5>\2</h5>',
		/\{\{(.+)\?(\d+)x(\d+)\|(.+)\}\}/ => '<img src="\1" width="\2" height="\3" title="\4" />',
		/\{\{(.+)\?(\d+)x(\d+)\}\}/ => '<img src="\1" width="\2" height="\3" />',
		/\{\{(.+)\?(\d+)\|(.+)\}\}/ => '<img src="\1" width="\2" title="\3" />',
		/\{\{(.+)\?(\d+)\}\}/ => '<img src="\1" width="\2" />',
		/\{\{(.+)\|(.+)\}\}/ => '<img src="\1" title="\2" />',
		/\{\{(.+)\}\}/ => '<img src="\1" />',
		/\[\[(.+)\|(.+)\]\]/ => '<a href="\1">\2</a>',
		/\[\[(.+)\]\]/ => '<a href="\1">\1</a>',
	#	/^\s+\*\s(.+)$/ => '<li>\1</li>'
	}

	# parse lists

	list_tokens = [/^(\s\s)+\*\s(.+)$/m , /^(\s\s)+-\s(.+)$/m ]

	#src.sub!(/(^\s+-\s(.+)$)+/m, '<ol>\1</ol>')
	#src.sub!(/(^\s+\*\s(.+)$)+/m, '<ul>\1</ul>')

	tokens.each do |k, v|
		while (src =~ k) do
			src.sub!(k, v)
		end
	end

	lines = src.split /\n/
	li_regex = /^((\s\s)+)(?=(\*|-)\s)/

	prev_line = lines.shift
	res = [prev_line]

	lines.each do |line|
		if (line.length <= 0)
			res << line
			next
		end

		l1, l2 = -1, -1

		l1 = li_regex.match(prev_line)[1].length if (li_regex =~ prev_line)
		l2 = li_regex.match(line)[1].length if (li_regex =~ line)

		#puts ":: #{l1}, #{l2} :: [ `#{prev_line}` (#{prev_line.length}), `#{line}` (#{line.length}) ]"

		if (l1 < 0) && (l2 > 0)
			res << line.sub(/^\s+\*\s(.+)$/, '<ul><li>\1')
		elsif (l1 > 0) && (l1 == l2)
			s = res.pop
			s += '</li>'
			res << s

			res << line.sub(/\s+\*\s(.+)$/, '<li>\1')
		elsif (l1 > 0) && (l2 > l1)
			s = res.pop
			s += '<ul>'
			res << s

			res << line.sub(/\s+\*\s(.+)$/, '<li>\1')
		elsif (l2 > 0) && (l1 > l2)
			s = res.pop
			s += '</li>' + ('</ul></li>' * ((l1 / 2) - 1))
			res << s

			res << line.sub(/\s+\*\s(.+)$/, '<li>\1')
		elsif (l1 > 0) && (l2 < 0)
			s = res.pop
			s += ('</li></ul>' * (l1 / 2))
			res << s

			res << line
		else
			res << line
		end
		
		prev_line = line
	end
	
	return res.join "\n"
end

s = <<'MOOENDOFSTRING'
DokuWiki supports **bold**, //italic//, __underlined__ and ''monospaced'' texts.
Of course you can **__//''combine''//__** all these.

You can use <sub>subscript</sub> and <sup>superscript</sup>, too.

You can mark something as <del>deleted</del> as well.

This is some text with some linebreaks\\ Note that the
two backslashes are only recognized at the end of a line\\
or followed by\\ a whitespace \\this happens without it.

DokuWiki supports multiple ways of creating links. External links are recognized
automagically: http://www.google.com or simply www.google.com - You can set
link text as well: [[http://www.google.com|This Link points to google]]. Email
addresses like this one: <andi@splitbrain.org> are recognized, too.

You can add footnotes ((This is a footnote with ((sub-footnote)) hehe)) by using double parentheses.

==== Headline Level 3 ====
=== Headline Level 4 ===
== Headline Level 5 ==

[[http://www.php.net|{{dokuwiki-128.png}}]]
[[http://www.php.net|{{dokuwiki-128.png|moofoo}}]]
{{dokuwiki-128.png|moofoo}}

Real size:                        {{dokuwiki-128.png}}
Resize to given width:            {{dokuwiki-128.png?50}}
Resize to given width and height: {{dokuwiki-128.png?200x50}}
Resized external image:           {{http://de3.php.net/images/php.gif?200x50}}

  * This is a list
  * The second item
    * You may have different levels
  * Another item

The end of string
MOOENDOFSTRING

puts "<pre>#{CGI.escapeHTML(s)}</pre>"
puts "<br />=========================================<br />"
puts markup(s)
