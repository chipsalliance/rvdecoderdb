// Style copy from https://github.com/roland-KA/basic-report-typst-template

#let gen-title(
  doc-category,
  doc-title,
  author,
  affiliation,
  heading-font,             // the heading-font is also used for all text on the titlepage
  heading-color,            // heading-color applies as well for the title
  info-size,                // used throughout the document for "info text"
  body-size,
  label-size,
) = {
  // ----- Page-Setup ------------------------
  set page(
    paper: "a4",
    margin: (top: 3cm, left: 4.5cm, right: 3cm, bottom: 4.5cm),
  )

  v(6cm)                    // = 4 x 1.5 cm

  // ----- Title Category & Title ------------------------
  align(
    left,                   // 1 x 14pt + 2 x 36pt ≈ 2 x 1.5 cm
    text(font: heading-font, weight: "regular", size: 14pt,
      doc-category),
  )

  text(font: heading-font, weight: "bold", size: 36pt,  fill: heading-color,
    doc-title,
  )

  // ----- Info Block ------------------------
  set par(leading: 1em)

  place(
    bottom + left,
    text(
      font: heading-font, weight: "regular", size: info-size, fill: black,
      datetime.today().display("[day].[month].[year]") + str("\n") +
      author + str("\n") +
      affiliation),
  )
}

#let project(
  doc-category: none,
  doc-title: none,
  author: none,
  affiliation: none,
  language: "en",
  show-outline: true,
  heading-color: blue,
  heading-font: "Noto Sans Mono",
  body,
) = {
  set document(title: doc-title, author: author)
  set text(lang: language)

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)", supplement: [])
  show math.equation: set block(spacing: 0.65em)

  let body-font = "Noto Serif"
  let body-size = 11pt

  // heading font is used in this size for kind of "information blocks"
  let info-size = 10pt

  // heading font is used in this size for different sorts of labels
  let label-size = 9pt

  // are we inside or outside of the outline (for roman/arabic page numbers)?
  let in-outline = state("in-outline", false)

  // ----- Basic Text- and Page-Setup ------------------------

  set text(
    font: body-font,
    size: body-size,
  )

  set par(
    justify: true,
    leading: 0.75em,
    spacing: 1.65em,
    first-line-indent: 0em,
    hanging-indent: 0pt,
  )

  // Page Grid:
  // Horizontal 1.5cm-grid = 14u: 3u left margin, 9u text, 2u right margin
  //     Idea: one-sided document; if printed on paper, the pages are often bound or stapled
  //     on the left side; so more space needed on the left. On-screen it doesn't matter.
  // Vertical 1.5cm-grid ≈ 20u: 2u top margin, 14u text, 2u botttom margin
  //     header with height ≈ 0.6cm is visually part of text block --> top margin = 3cm + 0.6cm
  set page(               // standard page with header
    paper: "a4",
    margin: (top: 3.6cm, left: 4.5cm, right: 3cm, bottom: 3cm),
    // the header shows the main chapter heading on the left and the page number on the right
    header: [
      #set text(0.8em)
      Sail Codegen #h(1fr) _Summary_
      #v(-0.5em)
      #line(length: 100%, stroke: 0.05em)
    ],
    footer: context [
      #set align(center)
      #counter(page).display()
    ],
    header-ascent: 1.5em
  )


  // ----- Headings & Numbering Schemes ------------------------

  set heading(numbering: "1.")
  show heading: set text(font: heading-font, fill: heading-color,
      weight: "bold")

  show heading.where(level: 1): it => {v(3.8 * body-size, weak: true) + block(it, height: 1.2 * body-size, sticky: true)}
  show heading.where(level: 2): it => {v(0.8 * body-size) + block(it, height: 1.2 * body-size, sticky: true)}
  show heading.where(level: 3): it => {v(0.8 * body-size) + block(it, height: 1 * body-size, sticky: true)}

  set figure(numbering: "1")
  show figure.caption: it => {
    set text(font: heading-font, size: label-size)
    block(it)
  }

  counter(page).update(0)
  gen-title(
    doc-category,
    doc-title,
    author,
    affiliation,
    heading-font,
    heading-color,
    info-size,
    body-size,
    label-size,
  )

  // ----- Table of Contents ------------------------

  // to detect, if inside or outside the outline (for different page numbers)
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  // top-level TOC entries in bold without filling
  show outline.entry.where(level: 1): it => {
    set block(above: 2 * body-size)
    set text(font: heading-font, weight: "bold", size: info-size)
    link(
      it.element.location(),    // make entry linkable
      it.indented(it.prefix(), it.body() + box(width: 1fr,) +  strong(it.page()))
    )
  }

  // other TOC entries in regular with adapted filling
  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => {
    set block(above: 0.8 * body-size)
    set text(font: heading-font, size: info-size)
    link(
      it.element.location(),  // make entry linkable
      it.indented(
          it.prefix(),
          it.body() + "  " +
            box(width: 1fr, repeat([.], gap: 2pt)) +
            "  " + it.page()
      )
    )
  }
  outline(
    title: if language == "de" {
      "Inhalt"
    } else if language == "fr" {
      "Table des matières"
    } else if language == "es" {
      "Contenido"
    } else if language == "it" {
      "Indice"
    } else if language == "nl" {
      "Inhoud"
    } else if language == "pt" {
      "Índice"
    } else if language == "zh" {
      "目录"
    } else if language == "ja" {
      "目次"
    } else if language == "ru" {
      "Содержание"
    } else if language == "ar" {
      "المحتويات"
    } else {
      "Contents"
    },
    indent: auto,
  )
  counter(page).update(0)

  pagebreak()

  show table.cell: set text(size: 0.9em)
  set table(align: left)
  // ----- Body Text ------------------------

  body
}
