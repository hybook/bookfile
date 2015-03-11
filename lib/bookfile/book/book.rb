# encoding: utf-8

###
## todo/fix:
##    render - auto-include opts
##    build book twice (std, and inline:true)
##  fix: locals - how to set for binding ???

module Bookfile

=begin
module PageHelper
  ## auto-load helpers here
  def render_toc
    "render_toc"
  end
 
  def render_country( country )
    "render_country #{country.name}"
  end
end
=end


## todo/fix: move to book/config.rb - why, why not??

class BookConfig
  def initialize( hash={} )
    @hash = hash
  end
  
  def templates_dir
    @hash[:templates_dir]
  end
end


class PageCtx    ## page context for evaluate

  ### include PageHelper
  include HybookHelper

  def initialize( config )   ## BookConfig
    ## pass in templates_dir here
    ##   ## TEMPLATES_DIR = ??  -- passed in as config
    ##  or pass in class to help find templates???
    ##  TemplateMan( ??? )
    @config = config
  end

  def write( text )
    puts "*** write:"
    puts "  #{text}"
  end

  def render( name, opts={}, locals={} )  ## possible? - make opts required ??
    puts "*** render #{name}:"

    ## todo/fix: how to make locals hash into local variables for binding ??
    ## use eval for now??
    ## alternative method 1:
    ## b = binding
    ## b.local_variable_set(:a, 'a')
    ## b.local_variable_set(:b, 'b')
    ##
    ## alternative method 2:
    ## see http://stackoverflow.com/questions/8954706/render-an-erb-template-with-values-from-a-hash ??

    tmpl  = File.read_utf8( "#{@config.templates_dir}/#{name}.md" )  ## name e.g. includes/_city

    ### check/fix: trouble with multiple method entries?? e.g. new binding on every call?
    ##    or gets reused (and, thus, we add more and more locals?? )
    locals.each do |k,v|
      puts "  add local '#{k}' #{k.class.name} - #{v.class.name}"
    end

    text  = TextUtils::PageTemplate.new( tmpl ).render( binding )

    ## use openstruct wrapper - why? why not??
    ## text  = TextUtils::PageTemplate.new( tmpl ).render(  OpenStruct.new(locals).instance_eval { binding }  )

    puts "  #{text}"
    text
  end

end  # class PageCtx



class BookCtx

  def initialize( config )
    @config = config
  end

  def page( name, opts={} )  ## &block
    puts "[BookCtx#page] #{name} opts:#{opts.inspect}"
    
    puts "[BookCtx#page] before yield"
    ctx = PageCtx.new( @config )   ## pass along book configs
    yield( ctx )  ## same as - ctx.instance_eval( &block )
    puts "[BookCtx#page] after yield"
  end

end  # class BootCtx


class BookDef
  def initialize( opts={}, proc )
    @opts = opts
    @proc = proc    ## use name block (why,why not??)
    ## @block = block  ## save block as proc ?? ??
  end

  def build
    config = BookConfig.new( templates_dir: './book/_templates' )
    ctx = BookCtx.new( config )
    @proc.call( ctx )  ## same as - ctx.instance_eval( &@codeblock ) -- use instance_eval - why, why not??
  end
end  # class BookDef


end # module Bookfile

