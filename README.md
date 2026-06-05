# RMK

A simple Markdown to HTML converter written in Raku. 

## Supported Features

* **Blocks:** Headers (`#`), Paragraphs, Code Blocks (4 spaces, 3 backticks), Blockquotes (`>`), Unordered Lists (`-`, `*`, `+`), Ordered Lists (`1.`), and Horizontal Rules (`---`).
* **Inline:** **Bold**, *Italics*, `Inline Code`, [Links](url), and ![Images](url).

## Usage

You can use RMK directly from the command line. Make sure the script is executable:

```bash
Usage:
  ./rmk.raku [<in>] [--out[=Any]]
  
    [<in>]         Input file in markdown format [default: <STDIN>]
    --out[=Any]    Output path in html format [default: <STDOUT>]
```
