ScreenShot = do ->
  gCxt = elements = imgConf = null

  _init = ( conf ) ->
    elements = _create( conf.root, conf.getImgUrl )
    gCxt = elements.canvas.getContext( '2d' )
    gCxt.fillStyle = 'transparent'
    setTimeout ->
      _invokeJqueryPlugs( conf.root )
      return
    , 2000
    return

  # 调用jQuery插件
  _invokeJqueryPlugs = ( root ) ->
    $( '#drag' ).draggable
      drag: ->
        _setView( _getCutData( this ) )
        _restrictDragPos( this, root )

    $( '#drag' ).resizable
      minWidth: 100
      minHeight: 100
      maxWidth: imgConf.width - 2
      maxHeight: imgConf.height - 2
      resize: ->
        _setView( _getCutData( this ) )
    return

  # 返回裁剪图片时所需要用的数据
  _getCutData = ( drag ) ->
    item = $( drag )
    {left, top} = item.position()

    {sw, sh} =
      sw: item.width()
      sh: item.height()

    {sx, sy} =
      sx: left - imgConf.left
      sy: top - imgConf.top

    {dw, dh} =
      dw: elements.canvas.width
      dh: elements.canvas.height

    {
      img: imgConf.img
      sx: sx / imgConf.width * imgConf.orgWidth
      sy: sy / imgConf.height * imgConf.orgHeight
      sw: sw / imgConf.width * imgConf.orgWidth
      sh: sh / imgConf.height * imgConf.orgHeight
      dx: 0
      dy: 0
      dw: dw
      dh: dh
    }

  # 显示被裁剪原图
  _setView = ( conf ) ->
    if conf.sx >= 0 and conf.sy >= 0
      gCxt.clearRect( 0, 0, conf.dw, conf.dh )
      gCxt.drawImage( conf.img, conf.sx, conf.sy, conf.sw, conf.sh, conf.dx, conf.dy, conf.dw, conf.dh )
    return

  # 获取裁剪后图片的地址
  _getImgUrl = ( callback ) ->
    if elements.canvas.toDataURL?()
      element.canvas.toDataURL()
      src = elements.canvas.toDataURL( 'image/png' )
      $( '#cuted' ).attr( 'src', src )
      callback?( src );
      return src

  # 限制拖拽元素的最大位移
  _restrictDragPos = ( drag, root ) ->
    item = $( drag )
    { left, top } = item.position()
    { width, height } =
      width: item.width()
      height: item.height()

    if left < imgConf.left
      item.css
        left: imgConf.left + 5
      return no

    if top < imgConf.top
      item.css
        top: imgConf.top + 5
      return no

    if left + width > imgConf.left + imgConf.width
      item.css
        left: left - ( ( left + width ) - ( imgConf.left + imgConf.width ) ) - 7
      return no

    if top + height > imgConf.top + imgConf.height
      item.css
        top: top - ( ( top + height ) - ( imgConf.top + imgConf.height ) ) - 7
      return no
    return yes

  # 创建canvas和拖拽对象
  _create = ( id, getImgUrl ) ->
    root = $( id ).css
      position: 'relative'
      lineHeight: $( id ).height() + 'px'

    canvas = $( '<canvas>' ).css
      float: 'left'
      width: '200px'
      height: '200px'
      float: 'right'

    clipBtn = $( '<input type="button" value="裁剪">' ).css
      display: 'block'

    clipBtn.click ->
      _getImgUrl( getImgUrl )
      return

    img = $( '<img>' ).attr( 'src', 'images/5.jpg' )
    img.attr( 'id', 'source-image' )
    img.bind 'load', ->
      {orgWidth, orgHeight} =
        orgWidth: $( this ).width()
        orgHeight: $( this ).height()

      imgConf =
        img: this
        orgWidth: orgWidth
        orgHeight: orgHeight

      $( this ).css
        width: '400px'
        height: 'auto'
        verticalAlign: 'middle'

      {left, top} = $( this ).position()
      $.extend( imgConf,
        left: left
        top: top
        width: $( this ).width()
        height: $( this ).height()
      )

      drag = $( '<div>' ).attr( 'id', 'drag' ).css
        position: 'absolute'
        width: '100px'
        height: '100px'
        left: left + 5 + 'px'
        top: top + 5 + 'px'
        cursor: 'move'
        border: '3px dotted #fff'
        backgroundColor: 'rgba( 255, 255, 255, 0 )'
      drag.addClass( "drag" )

      root.append( drag )
      return

    root.append( img )
    root.before( canvas, clipBtn )
    if $.browser.msie and $.browser.version < 9
      # 此方法来自于excanvas.js
      # 用以初始化动态创建的canvas
      canvas = window.G_vmlCanvasManager.initElement( canvas.get( 0 ) )
    else
      canvas = canvas.get( 0 )

    {
      canvas: canvas
    }

  {
    init: _init
  }
