$.widget 'cyclops.navbar',
  _create: ->
    menu = this.element.find '.navbar-collapse'
    btn = this.element.find '.navbar-toggle'
    isVisible = menu.is ':visible'
    menu.attr 'aria-expanded', isVisible
    btn.attr 'aria-expanded', isVisible
    btn.on 'click.cyclops', (event) =>
      this._toogle(event)

  _toogle: (event) ->
    btn = $(event.target)
    menu = btn.parents('.navbar').find('.navbar-collapse')
    if menu.is(':visible')
      menu.stop().slideUp 300, =>
        this._setAriaAndClass(menu, btn)
    else
      menu.stop().slideDown 300, =>
        this._setAriaAndClass(menu, btn)
    return

  _setAriaAndClass: (menu, btn) ->
    isVisible = menu.is(':visible')
    menu.attr('aria-expanded', isVisible)
    btn.attr('aria-expanded', isVisible)
    if(isVisible)
      menu.removeClass('collapsed')
      btn.addClass('open')
    else
      menu.addClass('collapsed')
      btn.removeClass('open')
    return

  _destroy: ->
    # remove all namespaced handlers
    btn = this.element.find '.navbar-toggle'
    btn.off '.cyclops'

#Automatically wireup navbar responsive behavior
$(() ->
  $("nav.navbar").each (idx, nb) ->
    $(nb).navbar()
)
