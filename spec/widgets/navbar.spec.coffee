describe 'Widgets: navabr', ->
  beforeEach jasmine.prepareTestNode

  it 'hangs off the global jquery fn object', ->
    expect(jQuery.fn.navbar).toBeDefined()

  it 'hides and shows menu when button clicked', ->
    nb = $("""
      <nav class="navbar navbar-static-top nav-cyclops">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="./">brand</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="index.html">Index</a></li>
          </ul>
          <div class="navbar-cl-logo"></div>
      </div>
    """)
    $(testNode).append nb
    $("nav.navbar").navbar()

    $("button").click()
    expect($(".navbar-collapse").is(":visible"), true)
    $("button").click()
    expect($(".navbar-collapse").is(":visible"), false)

  it 'adds correct aria classes', ->
    nb = $("""
      <nav class="navbar navbar-static-top nav-cyclops">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="./">brand</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="index.html">Index</a></li>
          </ul>
          <div class="navbar-cl-logo"></div>
      </div>
    """)
    $(testNode).append nb
    $("nav.navbar").navbar()

    $("button").click()
    expect($(".navbar-collapse").attr('aria-expanded'), true)
    expect($("button").attr('aria-expanded'), true)
    $("button").click()
    expect($(".navbar-collapse").attr('aria-expanded'), false)
    expect($("button").attr('aria-expanded'), false)

  it 'hides and shows menu when button clicked', ->
    nb = $("""
      <nav class="navbar navbar-static-top nav-cyclops">
        <div class="container-fluid">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="./">brand</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li><a href="index.html">Index</a></li>
          </ul>
          <div class="navbar-cl-logo"></div>
      </div>
    """)
    $(testNode).append nb
    widget = $("nav.navbar").navbar()
    expect($._data( $('button')[0], 'events' ).click).toBeDefined()
    widget.navbar("destroy")
    expect($._data( $('button')[0], 'events' )).toBeUndefined()
