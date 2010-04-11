#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../test_helper'

class ExtendTest < Test::Unit::TestCase
  def test_basic
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }
CSS
.foo {a: b}
.bar {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }
CSS
.bar {@extend .foo}
.foo {a: b}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }

.bar {
  c: d; }
CSS
.foo {a: b}
.bar {c: d; @extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }

.bar {
  c: d; }
CSS
.foo {a: b}
.bar {@extend .foo; c: d}
SCSS
  end

  def test_indented_syntax
    assert_equal <<CSS, render(<<SASS, :syntax => :sass)
.foo, .bar {
  a: b; }
CSS
.foo
  a: b
.bar
  @extend .foo
SASS

    assert_equal <<CSS, render(<<SASS, :syntax => :sass)
.foo, .bar {
  a: b; }
CSS
.foo
  a: b
.bar
  @extend \#{".foo"}
SASS
  end

  def test_multiple_targets
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }

.blip .foo, .blip .bar {
  c: d; }
CSS
.foo {a: b}
.bar {@extend .foo}
.blip .foo {c: d}
SCSS
  end

  def test_multiple_extendees
    assert_equal <<CSS, render(<<SCSS)
.foo, .baz {
  a: b; }

.bar, .baz {
  c: d; }
CSS
.foo {a: b}
.bar {c: d}
.baz {@extend .foo; @extend .bar}
SCSS
  end

  def test_multiple_extends_with_single_extender_and_single_target
    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .baz .bar, .foo .baz, .baz .baz {
  a: b; }
CSS
.foo .bar {a: b}
.baz {@extend .foo; @extend .bar}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar.baz, .foo.baz, .baz {
  a: b; }
CSS
.foo.bar {a: b}
.baz {@extend .foo; @extend .bar}
SCSS
  end

  def test_multiple_extends_with_multiple_extenders_and_single_target
    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .baz .bar, .foo .bang, .baz .bang {
  a: b; }
CSS
.foo .bar {a: b}
.baz {@extend .foo}
.bang {@extend .bar}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar.baz, .foo.bang, .baz.bang {
  a: b; }
CSS
.foo.bar {a: b}
.baz {@extend .foo}
.bang {@extend .bar}
SCSS
  end

  def test_chained_extends
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar, .baz, .bip {
  a: b; }
CSS
.foo {a: b}
.bar {@extend .foo}
.baz {@extend .bar}
.bip {@extend .bar}
SCSS
  end

  def test_dynamic_extendee
    assert_equal <<CSS, render(<<SCSS)
.foo, .bar {
  a: b; }
CSS
.foo {a: b}
.bar {@extend \#{".foo"}}
SCSS

    assert_equal <<CSS, render(<<SCSS)
[baz^="blip12px"], .bar {
  a: b; }
CSS
[baz^="blip12px"] {a: b}
.bar {@extend [baz^="blip\#{12px}"]}
SCSS
  end

  def test_nested_target
    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .foo .baz {
  a: b; }
CSS
.foo .bar {a: b}
.baz {@extend .bar}
SCSS
  end

  def test_target_with_child
    assert_equal <<CSS, render(<<SCSS)
.foo .bar, .baz .bar {
  a: b; }
CSS
.foo .bar {a: b}
.baz {@extend .foo}
SCSS
  end

  def test_class_unification
    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar.baz {
  a: b; }
CSS
.foo.bar {a: b}
.baz {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.baz, .baz {
  a: b; }
CSS
.foo.baz {a: b}
.baz {@extend .foo}
SCSS
  end

  def test_id_unification
    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar#baz {
  a: b; }
CSS
.foo.bar {a: b}
#baz {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo#baz, #baz {
  a: b; }
CSS
.foo#baz {a: b}
#baz {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo#baz {
  a: b; }
CSS
.foo#baz {a: b}
#bar {@extend .foo}
SCSS
  end

  def test_universal_unification_with_simple_target
    assert_equal <<CSS, render(<<SCSS)
.foo, * {
  a: b; }
CSS
.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo, *|* {
  a: b; }
CSS
.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar {
  a: b; }
CSS
.foo.bar {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar {
  a: b; }
CSS
.foo.bar {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, ns|*.bar {
  a: b; }
CSS
.foo.bar {a: b}
ns|* {@extend .foo}
SCSS
  end

  def test_universal_unification_with_namespaceless_universal_target
    assert_equal <<CSS, render(<<SCSS)
*.foo, * {
  a: b; }
CSS
*.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*.foo, * {
  a: b; }
CSS
*.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|*.foo, * {
  a: b; }
CSS
*|*.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|*.foo, *|* {
  a: b; }
CSS
*|*.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*.foo, ns|* {
  a: b; }
CSS
*.foo {a: b}
ns|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|*.foo, ns|* {
  a: b; }
CSS
*|*.foo {a: b}
ns|* {@extend .foo}
SCSS
  end

  def test_universal_unification_with_namespaced_universal_target
    assert_equal <<CSS, render(<<SCSS)
ns|*.foo, ns|* {
  a: b; }
CSS
ns|*.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|*.foo, ns|* {
  a: b; }
CSS
ns|*.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns1|*.foo {
  a: b; }
CSS
ns1|*.foo {a: b}
ns2|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|*.foo, ns|* {
  a: b; }
CSS
ns|*.foo {a: b}
ns|* {@extend .foo}
SCSS
  end

  def test_universal_unification_with_namespaceless_element_target
    assert_equal <<CSS, render(<<SCSS)
a.foo, a {
  a: b; }
CSS
a.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo, a {
  a: b; }
CSS
a.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|a.foo, a {
  a: b; }
CSS
*|a.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|a.foo, *|a {
  a: b; }
CSS
*|a.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo, ns|a {
  a: b; }
CSS
a.foo {a: b}
ns|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|a.foo, ns|a {
  a: b; }
CSS
*|a.foo {a: b}
ns|* {@extend .foo}
SCSS
  end

  def test_universal_unification_with_namespaced_element_target
    assert_equal <<CSS, render(<<SCSS)
ns|a.foo, ns|a {
  a: b; }
CSS
ns|a.foo {a: b}
* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|a.foo, ns|a {
  a: b; }
CSS
ns|a.foo {a: b}
*|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns1|a.foo {
  a: b; }
CSS
ns1|a.foo {a: b}
ns2|* {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|a.foo, ns|a {
  a: b; }
CSS
ns|a.foo {a: b}
ns|* {@extend .foo}
SCSS
  end

  def test_element_unification_with_simple_target
    assert_equal <<CSS, render(<<SCSS)
.foo, a {
  a: b; }
CSS
.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, a.bar {
  a: b; }
CSS
.foo.bar {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, *|a.bar {
  a: b; }
CSS
.foo.bar {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
.foo.bar, ns|a.bar {
  a: b; }
CSS
.foo.bar {a: b}
ns|a {@extend .foo}
SCSS
  end

  def test_element_unification_with_namespaceless_universal_target
    assert_equal <<CSS, render(<<SCSS)
*.foo, a {
  a: b; }
CSS
*.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*.foo, a {
  a: b; }
CSS
*.foo {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|*.foo, a {
  a: b; }
CSS
*|*.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|*.foo, *|a {
  a: b; }
CSS
*|*.foo {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*.foo, ns|a {
  a: b; }
CSS
*.foo {a: b}
ns|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|*.foo, ns|a {
  a: b; }
CSS
*|*.foo {a: b}
ns|a {@extend .foo}
SCSS
  end

  def test_element_unification_with_namespaced_universal_target
    assert_equal <<CSS, render(<<SCSS)
ns|*.foo, ns|a {
  a: b; }
CSS
ns|*.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|*.foo, ns|a {
  a: b; }
CSS
ns|*.foo {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns1|*.foo {
  a: b; }
CSS
ns1|*.foo {a: b}
ns2|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|*.foo, ns|a {
  a: b; }
CSS
ns|*.foo {a: b}
ns|a {@extend .foo}
SCSS
  end

  def test_element_unification_with_namespaceless_element_target
    assert_equal <<CSS, render(<<SCSS)
a.foo, a {
  a: b; }
CSS
a.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo, a {
  a: b; }
CSS
a.foo {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|a.foo, a {
  a: b; }
CSS
*|a.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|a.foo, *|a {
  a: b; }
CSS
*|a.foo {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo, ns|a {
  a: b; }
CSS
a.foo {a: b}
ns|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
*|a.foo, ns|a {
  a: b; }
CSS
*|a.foo {a: b}
ns|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo {
  a: b; }
CSS
a.foo {a: b}
h1 {@extend .foo}
SCSS
  end

  def test_element_unification_with_namespaced_element_target
    assert_equal <<CSS, render(<<SCSS)
ns|a.foo, ns|a {
  a: b; }
CSS
ns|a.foo {a: b}
a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|a.foo, ns|a {
  a: b; }
CSS
ns|a.foo {a: b}
*|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns1|a.foo {
  a: b; }
CSS
ns1|a.foo {a: b}
ns2|a {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
ns|a.foo, ns|a {
  a: b; }
CSS
ns|a.foo {a: b}
ns|a {@extend .foo}
SCSS
  end

  def test_attribute_unification
    assert_equal <<CSS, render(<<SCSS)
[foo=bar].baz, [foo=bar][foo=baz] {
  a: b; }
CSS
[foo=bar].baz {a: b}
[foo=baz] {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
[foo=bar].baz, [foo=bar][foo^=bar] {
  a: b; }
CSS
[foo=bar].baz {a: b}
[foo^=bar] {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
[foo=bar].baz, [foo=bar][foot=bar] {
  a: b; }
CSS
[foo=bar].baz {a: b}
[foot=bar] {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
[foo=bar].baz, [foo=bar][ns|foo=bar] {
  a: b; }
CSS
[foo=bar].baz {a: b}
[ns|foo=bar] {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
[foo=bar].baz, [foo=bar] {
  a: b; }
CSS
[foo=bar].baz {a: b}
[foo=bar] {@extend .baz}
SCSS
  end

  def test_pseudo_unification
    assert_equal <<CSS, render(<<SCSS)
:foo.baz, :foo:foo(2n+1) {
  a: b; }
CSS
:foo.baz {a: b}
:foo(2n+1) {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
:foo.baz, :foo::foo {
  a: b; }
CSS
:foo.baz {a: b}
::foo {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
::foo.baz {
  a: b; }
CSS
::foo.baz {a: b}
::bar {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
::foo.baz {
  a: b; }
CSS
::foo.baz {a: b}
::foo(2n+1) {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
::foo.baz, ::foo {
  a: b; }
CSS
::foo.baz {a: b}
::foo {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
::foo(2n+1).baz, ::foo(2n+1) {
  a: b; }
CSS
::foo(2n+1).baz {a: b}
::foo(2n+1) {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
:foo.baz, :foo:bar {
  a: b; }
CSS
:foo.baz {a: b}
:bar {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
:foo.baz, :foo {
  a: b; }
CSS
:foo.baz {a: b}
:foo {@extend .baz}
SCSS
  end

  def test_pseudoelement_remains_at_end_of_selector
    assert_equal <<CSS, render(<<SCSS)
.foo::bar, .baz::bar {
  a: b; }
CSS
.foo::bar {a: b}
.baz {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo::bar, a.baz::bar {
  a: b; }
CSS
a.foo::bar {a: b}
.baz {@extend .foo}
SCSS
  end

  def test_negation_unification
    assert_equal <<CSS, render(<<SCSS)
:not(.foo).baz, :not(.foo):not(.bar) {
  a: b; }
CSS
:not(.foo).baz {a: b}
:not(.bar) {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
:not(.foo).baz, :not(.foo) {
  a: b; }
CSS
:not(.foo).baz {a: b}
:not(.foo) {@extend .baz}
SCSS

    assert_equal <<CSS, render(<<SCSS)
:not([a=b]).baz, :not([a=b]) {
  a: b; }
CSS
:not([a=b]).baz {a: b}
:not([a = b]) {@extend .baz}
SCSS
  end

  ## Long Extendees

  def test_long_extendee
    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .baz {
  a: b; }
CSS
.foo.bar {a: b}
.baz {@extend .foo.bar}
SCSS
  end

  def test_long_extendee_requires_all_selectors
    assert_equal <<CSS, render(<<SCSS)
.foo {
  a: b; }
CSS
.foo {a: b}
.baz {@extend .foo.bar}
SCSS
  end

  def test_long_extendee_matches_supersets
    assert_equal <<CSS, render(<<SCSS)
.foo.bar.bap, .bap.baz {
  a: b; }
CSS
.foo.bar.bap {a: b}
.baz {@extend .foo.bar}
SCSS
  end

  def test_long_extendee_runs_unification
    assert_equal <<CSS, render(<<SCSS)
ns|*.foo.bar, ns|a.baz {
  a: b; }
CSS
ns|*.foo.bar {a: b}
a.baz {@extend .foo.bar}
SCSS
  end

  ## Long Extenders

  def test_long_extender
    assert_equal <<CSS, render(<<SCSS)
.foo.bar, .bar.baz.bang {
  a: b; }
CSS
.foo.bar {a: b}
.baz.bang {@extend .foo}
SCSS
  end

  def test_long_extender_runs_unification
    assert_equal <<CSS, render(<<SCSS)
ns|*.foo.bar, ns|a.bar.baz {
  a: b; }
CSS
ns|*.foo.bar {a: b}
a.baz {@extend .foo}
SCSS
  end

  def test_long_extender_aborts_unification
    assert_equal <<CSS, render(<<SCSS)
a.foo#bar {
  a: b; }
CSS
a.foo#bar {a: b}
h1.baz {@extend .foo}
SCSS

    assert_equal <<CSS, render(<<SCSS)
a.foo#bar {
  a: b; }
CSS
a.foo#bar {a: b}
.bang#baz {@extend .foo}
SCSS
  end

  private

  def render(sass, options = {})
    munge_filename options
    Sass::Engine.new(sass, {:syntax => :scss}.merge(options)).render
  end
end
