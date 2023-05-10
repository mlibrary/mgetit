require "yaml"

if "".respond_to?(:encoding)

  class EncodingTest < Test::Unit::TestCase
    def test_kev
      # Load from string explicitly set to binary, to make sure it ends up utf-8
      # anyhow.
      raw_kev = "url_ver=Z39.88-2004&url_tim=2003-04-11T10%3A09%3A15TZD&url_ctx_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Actx&ctx_ver=Z39.88-2004&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&ctx_id=10_8&ctx_tim=2003-04-11T10%3A08%3A30TZD&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&rft.genre=book&rft.aulast=Vergnaud&rft.auinit=J.-R&rft.btitle=D%C3%A9pendances+et+niveaux+de+repr%C3%A9sentation+en+syntaxe&rft.date=1985&rft.pub=Benjamins&rft.place=Amsterdam%2C+Philadelphia&rfe_id=urn%3Aisbn%3A0262531283&rfe_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&rfe.genre=book&rfe.aulast=Chomsky&rfe.auinit=N&rfe.btitle=Minimalist+Program&rfe.isbn=0262531283&rfe.date=1995&rfe.pub=The+MIT+Press&rfe.place=Cambridge%2C+Mass&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Asch_svc&svc.abstract=yes&rfr_id=info%3Asid%2Febookco.com%3Abookreader".force_encoding("ascii-8bit")

      assert_equal("ASCII-8BIT", raw_kev.encoding.name)

      ctx = OpenURL::ContextObject.new_from_kev(raw_kev)

      assert_equal("UTF-8", ctx.referent.metadata["btitle"].encoding.name)
      assert_equal("Dépendances et niveaux de représentation en syntaxe", ctx.referent.metadata["btitle"])

      # serialized as utf-8
      assert_equal("UTF-8", ctx.kev.encoding.name)
    end

    def test_xml
      assert_equal("ASCII-8BIT", @@xml_with_utf8.encoding.name)

      ctx = OpenURL::ContextObject.new_from_xml(@@xml_with_utf8)

      assert_equal("UTF-8", ctx.referent.metadata["btitle"].encoding.name)
      assert_equal("Dépendances et niveaux de représentation en syntaxe", ctx.referent.metadata["btitle"])

      # serialized as utf-8
      assert_equal("UTF-8", ctx.xml.encoding.name)
    end

    # includes byte that are bad for UTF8, OpenURL auto replaces em.
    def test_bad_kev
      raw_kev = "&rft.pub=M\xE9xico".force_encoding("ascii-8bit")

      ctx = OpenURL::ContextObject.new_from_kev(raw_kev)

      assert_equal("UTF-8", ctx.referent.metadata["pub"].encoding.name)
      # replacement char
      assert_equal "M\uFFFDxico", ctx.referent.metadata["pub"]

      # serialized as utf-8i
      assert_equal("UTF-8", ctx.kev.encoding.name)
    end

    def test_bad_xml
      ctx = OpenURL::ContextObject.new_from_xml(@@xml_with_bad_utf8)

      assert_equal("UTF-8", ctx.referent.metadata["btitle"].encoding.name)
      assert_equal("D\uFFFDpendances et niveaux de représentation en syntaxe", ctx.referent.metadata["btitle"])

      # serialized as utf-8
      assert_equal("UTF-8", ctx.xml.encoding.name)
    end

    def test_bad_from_form_vars
      ctx = OpenURL::ContextObject.new_from_form_vars("btitle" => "M\xE9xico".force_encoding("binary"))

      assert_equal("UTF-8", ctx.referent.metadata["btitle"].encoding.name)
      assert_equal("M\uFFFDxico", ctx.referent.metadata["btitle"])

      assert_equal("UTF-8", ctx.kev.encoding.name)
    end

    def test_8859_kev
      # specify 8859-1 encoding.
      raw_kev = "ctx_enc=info%3Aofi%2Fenc%3AISO-8859-1"
      raw_kev += "&url_ver=Z39.88-2004&rft.btitle=M%E9xico".force_encoding("ascii-8bit")

      ctx = OpenURL::ContextObject.new_from_kev(raw_kev)

      # properly transcoded to UTF8
      assert_equal("UTF-8", ctx.referent.metadata["btitle"].encoding.name)
      assert_equal("México".force_encoding("UTF-8"), ctx.referent.metadata["btitle"])

      # serialized as utf-8
      assert_equal("UTF-8", ctx.kev.encoding.name)
      # with proper ctx_env, not the one previously specifying ISO-8859-1!

      assert_not_equal "info:ofi/enc:ISO-8859-1", CGI.parse(ctx.kev)["ctx_enc"].first
    end

    def test_8859_form_vars
      ctx = OpenURL::ContextObject.new_from_form_vars("btitle" => "M\xE9xico", "ctx_enc" => "info:ofi/enc:ISO-8859-1")

      assert_equal("UTF-8", ctx.referent.metadata["btitle"].encoding.name)
      assert_equal("México".force_encoding("UTF-8"), ctx.referent.metadata["btitle"])
    end

    @@xml_with_utf8 = <<~EOS
      <ctx:context-objects xmlns:ctx='info:ofi/fmt:xml:xsd:ctx' xsi:schemaLocation='info:ofi/fmt:xml:xsd:ctx http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:ctx' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'><ctx:context-object identifier='10_8' timestamp='2003-04-11T10:08:30TZD' version='Z39.88-2004'><ctx:referent><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:book</ctx:format><ctx:metadata><rft:book xmlns:rft='info:ofi/fmt:xml:xsd:book' xsi:schemaLocation='info:ofi/fmt:xml:xsd:book http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:book'><rft:genre>book</rft:genre><rft:btitle>Dépendances et niveaux de représentation en syntaxe</rft:btitle><rft:date>1985</rft:date><rft:pub>Benjamins</rft:pub><rft:place>Amsterdam, Philadelphia</rft:place><rft:authors><rft:author><rft:aulast>Vergnaud</rft:aulast><rft:auinit>J.-R</rft:auinit></rft:author></rft:authors></rft:book></ctx:metadata></ctx:metadata-by-val></ctx:referent><ctx:referring-entity><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:book</ctx:format><ctx:metadata><rfe:book xmlns:rfe='info:ofi/fmt:xml:xsd:book' xsi:schemaLocation='info:ofi/fmt:xml:xsd:book http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:book'><rfe:genre>book</rfe:genre><rfe:btitle>Minimalist Program</rfe:btitle><rfe:isbn>0262531283</rfe:isbn><rfe:date>1995</rfe:date><rfe:pub>The MIT Press</rfe:pub><rfe:place>Cambridge, Mass</rfe:place><rfe:authors><rfe:author><rfe:aulast>Chomsky</rfe:aulast><rfe:auinit>N</rfe:auinit></rfe:author></rfe:authors></rfe:book></ctx:metadata></ctx:metadata-by-val><ctx:identifier>urn:isbn:0262531283</ctx:identifier></ctx:referring-entity><ctx:referrer><ctx:identifier>info:sid/ebookco.com:bookreader</ctx:identifier></ctx:referrer><ctx:service-type><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:sch_svc</ctx:format><ctx:metadata><svc:abstract xmlns:svc='info:ofi/fmt:xml:xsd:sch_svc'>yes</svc:abstract></ctx:metadata></ctx:metadata-by-val></ctx:service-type></ctx:context-object></ctx:context-objects>
    EOS
    # Make sure it's got a raw encoding, so we can test it winds up utf-8 anyhow
    @@xml_with_utf8.force_encoding("ascii-8bit")

    @@xml_with_bad_utf8 = <<~EOS
      <ctx:context-objects xmlns:ctx='info:ofi/fmt:xml:xsd:ctx' xsi:schemaLocation='info:ofi/fmt:xml:xsd:ctx http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:ctx' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'><ctx:context-object identifier='10_8' timestamp='2003-04-11T10:08:30TZD' version='Z39.88-2004'><ctx:referent><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:book</ctx:format><ctx:metadata><rft:book xmlns:rft='info:ofi/fmt:xml:xsd:book' xsi:schemaLocation='info:ofi/fmt:xml:xsd:book http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:book'><rft:genre>book</rft:genre><rft:btitle>D\xE9pendances et niveaux de représentation en syntaxe</rft:btitle><rft:date>1985</rft:date><rft:pub>Benjamins</rft:pub><rft:place>Amsterdam, Philadelphia</rft:place><rft:authors><rft:author><rft:aulast>Vergnaud</rft:aulast><rft:auinit>J.-R</rft:auinit></rft:author></rft:authors></rft:book></ctx:metadata></ctx:metadata-by-val></ctx:referent><ctx:referring-entity><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:book</ctx:format><ctx:metadata><rfe:book xmlns:rfe='info:ofi/fmt:xml:xsd:book' xsi:schemaLocation='info:ofi/fmt:xml:xsd:book http://www.openurl.info/registry/docs/info:ofi/fmt:xml:xsd:book'><rfe:genre>book</rfe:genre><rfe:btitle>Minimalist Program</rfe:btitle><rfe:isbn>0262531283</rfe:isbn><rfe:date>1995</rfe:date><rfe:pub>The MIT Press</rfe:pub><rfe:place>Cambridge, Mass</rfe:place><rfe:authors><rfe:author><rfe:aulast>Chomsky</rfe:aulast><rfe:auinit>N</rfe:auinit></rfe:author></rfe:authors></rfe:book></ctx:metadata></ctx:metadata-by-val><ctx:identifier>urn:isbn:0262531283</ctx:identifier></ctx:referring-entity><ctx:referrer><ctx:identifier>info:sid/ebookco.com:bookreader</ctx:identifier></ctx:referrer><ctx:service-type><ctx:metadata-by-val><ctx:format>info:ofi/fmt:xml:xsd:sch_svc</ctx:format><ctx:metadata><svc:abstract xmlns:svc='info:ofi/fmt:xml:xsd:sch_svc'>yes</svc:abstract></ctx:metadata></ctx:metadata-by-val></ctx:service-type></ctx:context-object></ctx:context-objects>
    EOS
    @@xml_with_bad_utf8.force_encoding("ascii-8bit")
  end
else
  puts <<~EOS
      
    =================================================================
      WARNING: Can't run encoding tests unless under ruby 1.9 
          #{__FILE__} 
      Encoding tests will NOT be run.
    =================================================================
    
  EOS
end
