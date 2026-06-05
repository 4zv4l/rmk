#!/usr/bin/env raku

grammar TinyMD {
    token TOP                  { \s* <block>* \s* }
    proto token block          { * }
    token block:sym<hr>        { ^^ \h* <[-*_]> ** 3..99 \h* \n+ }
    token block:sym<header>    { ^^ $<lvl>=('#' ** 1..6) \h+ $<text>=\N+ \n* }
    token block:sym<fenced>    { ^^ '```' $<lang>=\N* \n $<text>=.*? ^^ '```' \n* }
    token block:sym<codeblock> { [ ^^ [ ' ' ** 4 | \t ] $<text>=\N+ \n* ]+ }
    token block:sym<quote>     { [ ^^ \h* '>' \h* $<text>=\N+ \n* ]+ }
    token block:sym<ul>        { [ ^^ \h* <[-*+]> \h+ $<text>=\N+ \n* ]+ }
    token block:sym<ol>        { [ ^^ \h* \d+ '.' \h+ $<text>=\N+ \n* ]+ }
    token block:sym<para>      { [ ^^ <!before <block-stop> > $<text>=\N+ \n* ]+ }
    token block-stop           { \h* [ <[-*_]>**3..99 | '#' | '>' | <[-*+]> \h | \d+ '.' \h | ' ' ** 4 | \t | '```' ] }
}

class MD-HTML {
    method TOP($/)                  { make $<block>.map(*.made).join("\n\n") }
    method block:sym<hr>($/)        { make "<hr>" }
    method block:sym<header>($/)    { make "<h{$<lvl>.chars}>" ~ $<text>.&inline ~ "</h{$<lvl>.chars}>" }
    method block:sym<codeblock>($/) { make "<pre><code>\n" ~ $<text>.join("\n").&htmlscape ~ "\n</code></pre>" }
    method block:sym<fenced>($/)    { make "<pre><code" ~ ($<lang>.trim ?? " class=\"language-{$<lang>.trim}\"" !! "") ~ ">\n" ~ $<text>.&htmlscape ~ "</code></pre>" }
    method block:sym<quote>($/)     { make "<blockquote>\n" ~ $<text>.map({"  <p>" ~ &.inline ~ "</p>"}).join("\n") ~ "\n</blockquote>" }
    method block:sym<para>($/)      { make "<p>\n  " ~ $<text>.join("\n").&inline ~ "\n</p>" }
    method block:sym<ul>($/)        { make "<ul>\n" ~ $<text>.map({"  <li>" ~ .&inline ~ "</li>"}).join("\n") ~ "\n</ul>" }
    method block:sym<ol>($/)        { make "<ol>\n" ~ $<text>.map({"  <li>" ~ .&inline ~ "</li>"}).join("\n") ~ "\n</ol>" }

    sub htmlscape($str) { $str.trans([ '<'   , '>'   , '&' ] => [ '&lt;', '&gt;', '&amp;' ]) }
    sub inline($str) {
        $str.subst(/ \! \[ (.*?) \] \( (.*?) \) /,    -> $/ { "<img src=\"$1\" alt=\"$0\">" },        :g) # Images
            .subst(/ \[ (.*?) \] \( (.*?) \) /,       -> $/ { "<a href=\"$1\">{$0}</a>" },            :g) # Links
            .subst(/ \*\* (.*?) \*\* | __ (.*?) __ /, -> $/ { "<strong>{ $0 || $1 }</strong>" },      :g) # bold
            .subst(/ \* (.*?) \* | _ (.*?) _ /,       -> $/ { "<em>{ $0 || $1 }</em>" },              :g) # italic
            .subst(/ (\`+) \h* (.+?) \h* $0 /,        -> $/ { "<code>" ~ $1.&htmlscape ~ "</code>" }, :g) # code
    }
}

my %*SUB-MAIN-OPTS = :named-anywhere;
sub MAIN(
    $in   = $*IN,  #= Input file in markdown format
    :$out = $*OUT, #= Output path in html format
) {
    my $text = $in ~~ IO::Handle ?? $in.slurp !! $in.IO.slurp;
    my $html = try TinyMD.parse($text, actions => MD-HTML.new).made orelse die "Failed to parse Markdown.";
    $out ~~ IO::Handle ?? $out.print($html) !! $out.IO.spurt($html);
}
