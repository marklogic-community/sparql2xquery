xquery version "1.0-ml";

(:
 : Copyright (c)2009-2010 Mark Logic Corporation
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 : http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :
 : The use of the Apache License does not indicate that this project is
 : affiliated with the Apache Software Foundation.
 :
 : library module of semantic functions
 :
 : @author Michael Blakeley, Mark Logic Corporation
 :)
module namespace sem = "http://marklogic.com/semantic";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare default collation 'http://marklogic.com/collation/codepoint';

declare variable $sem:DEBUG := false()
;

declare variable $sem:LEXICON-OPTIONS := (
  (: this is where we switch between docs and naked properties :)
  if (1) then ()
  else 'properties'
);

declare variable $sem:QN-S := xs:QName('s')
;

declare variable $sem:QN-O := xs:QName('o')
;

declare variable $sem:QN-P := xs:QName('p')
;

declare variable $sem:QN-C := xs:QName('c')
;

declare variable $sem:QN-H := xs:QName('h')
;

declare variable $sem:O-OWL-CLASS :=
'http://www.w3.org/2002/07/owl#Class'
;

declare variable $sem:O-OWL-OBJECT-PROPERTY :=
'http://www.w3.org/2002/07/owl#ObjectProperty'
;

declare variable $sem:O-RDF-NIL :=
'http://www.w3.org/1999/02/22-rdf-syntax-ns#nil'
;

declare variable $sem:P-OWL-INTERSECTION :=
'http://www.w3.org/2002/07/owl#intersectionOf'
;

declare variable $sem:P-OWL-ON-PROPERTY :=
'http://www.w3.org/2002/07/owl#onProperty'
;

declare variable $sem:P-RDF-FIRST :=
'http://www.w3.org/1999/02/22-rdf-syntax-ns#first'
;

declare variable $sem:P-RDF-LABEL :=
'http://www.w3.org/2000/01/rdf-schema#label'
;

declare variable $sem:P-RDF-REST :=
'http://www.w3.org/1999/02/22-rdf-syntax-ns#rest'
;

declare variable $sem:P-RDF-SUBCLASS :=
'http://www.w3.org/2000/01/rdf-schema#subClassOf'
;

declare variable $sem:P-RDF-SUBPROPERTY :=
'http://www.w3.org/2000/01/rdf-schema#subPropertyOf'
;

declare variable $sem:P-RDF-TYPE :=
'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
;

declare private function sem:rq(
  $qn as xs:QName+, $v as xs:string+)
as cts:query
{
  cts:element-range-query($qn, '=', $v)
};

declare private function sem:hq(
  $qn as xs:QName+, $v as xs:unsignedLong+)
as cts:query
{
  cts:element-attribute-range-query($qn, $sem:QN-H, '=', $v)
};

declare private function sem:ev(
  $qn as xs:QName+, $query as cts:query)
as xs:string*
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text { 'sem:ev', xdmp:describe($qn), xdmp:quote($query) })
  ,
  cts:element-values(
    $qn, (), $sem:LEXICON-OPTIONS, $query)
};

declare private function sem:hv(
  $qn as xs:QName+, $query as cts:query)
as xs:unsignedLong*
{
  cts:element-attribute-values(
    $qn, $QN-H, (), $sem:LEXICON-OPTIONS, $query)
};

declare private function sem:pq(
  $p as xs:string+)
 as cts:query
{
  sem:hq($sem:QN-P, xdmp:hash64($p))
};

declare private function sem:opq(
  $o as xs:string+, $p as xs:string+)
 as cts:query
{
  cts:and-query((sem:rq($sem:QN-O, $o), sem:pq($p)))
};

declare private function sem:spq(
  $s as xs:string+, $p as xs:string+)
 as cts:query
{
  cts:and-query((sem:rq($sem:QN-S, $s), sem:pq($p)))
};

declare private function sem:sopq(
  $s as xs:string+, $o as xs:string+, $p as xs:string+)
 as cts:query
{
  cts:and-query((sem:rq($sem:QN-S, $s), sem:rq($sem:QN-O, $o), sem:pq($p)))
};

declare function sem:object-for-predicate(
  $p as xs:string+)
as xs:string*
{
  if (empty($p)) then ()
  else sem:ev($sem:QN-O, sem:pq($p))
};

declare function sem:subject-for-predicate(
  $p as xs:string+)
as xs:string*
{
  if (empty($p)) then ()
  else sem:ev($sem:QN-S, sem:pq($p))
};

declare function sem:object-for-object-predicate(
  $s as xs:string*, $p as xs:string+)
as xs:string*
{
  if (empty($s)) then ()
  else sem:ev($sem:QN-O, sem:opq($s, $p))
};

declare function sem:object-for-subject-predicate(
  $s as xs:string*, $p as xs:string+)
as xs:string*
{
  if (empty($s)) then ()
  else sem:ev($sem:QN-O, sem:spq($s, $p))
};

declare function sem:subject-for-object-predicate(
   $o as xs:string*, $p as xs:string+)
as xs:string*
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text { 'sem:subject-for-object-predicate', $o, $p })
  ,
  if (empty($o)) then ()
  else sem:ev($sem:QN-S, sem:opq($o, $p))
};

declare function sem:subject-for-subject-predicate(
   $s as xs:string*, $p as xs:string+)
as xs:string*
{
  if (empty($s)) then ()
  else sem:ev($sem:QN-S, sem:spq($s, $p))
};

declare function sem:object-by-subject-object-predicate(
  $s as xs:string+,
  $o as xs:string+,
  $p as xs:string+)
as xs:string*
{
  sem:ev($sem:QN-O, sem:sopq($s, $o, $p))
};

declare function sem:subject-by-subject-object-predicate(
  $s as xs:string+,
  $o as xs:string+,
  $p as xs:string+)
as xs:string*
{
  sem:ev($sem:QN-S, sem:sopq($s, $o, $p))
};

declare private function sem:transitive-closure-filter(
  $m as map:map, $candidates as xs:string*,
  $filters as xs:string*, $gen as xs:integer)
 as xs:string*
{
  (: use lexicons to filter :)
  (: are we done yet? :)
  if (empty($candidates)) then ()
  else if (empty($filters)) then (
    if (not($sem:DEBUG)) then ()
    else xdmp:log(text {
        'transitive-closure-filter put', $gen, count($candidates) }),
    (: update the map :)
    for $c in $candidates
    where empty(map:get($m, $c))
    return (
      map:put($m, $c, $gen),
      (: yields sequence of filtered candidates from this generation :)
      $c
    )
  )
  else (
    let $this := $filters[1]
    let $rest := subsequence($filters, 2)
    let $next := sem:subject-for-subject-predicate($candidates, $this)
    let $d := (
      if (not($sem:DEBUG)) then ()
      else xdmp:log(text {
          'transitive-closure-filter gen',
          $gen, count($candidates), count($filters) })
    )
    where exists($next)
    return sem:transitive-closure-filter($m, $next, $rest, $gen)
  )
};

declare function sem:transitive-closure(
  $m as map:map, $seeds as xs:string*, $gen as xs:integer,
  $relation as xs:string, $direction as xs:boolean, $filters as xs:string*)
 as empty-sequence()
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text {
      'transitive-closure start of gen',
      $gen, count($seeds), count(map:keys($m)) }),
  (: apply dummy empty filter, on bootstrap generation only :)
  if (exists(map:keys($m))) then () else (
    let $do := sem:transitive-closure-filter($m, $seeds, (), $gen)
    return ()
  ),
  (: are we done yet? :)
  if ($gen lt 1 or empty($seeds)) then (
    if (not($sem:DEBUG)) then ()
    else xdmp:log(text {
        'transitive-closure end at gen',
        $gen, count($seeds), count(map:keys($m)) })
  )
  else (
    (: get the next generation of friends :)
    let $new-friends := (
      if ($direction) then sem:object-for-subject-predicate($seeds, $relation)
      else sem:subject-for-object-predicate($seeds, $relation)
    )
    let $d := (
      if (not($sem:DEBUG)) then ()
      else xdmp:log(text {
        'transitive-closure gen',
          $gen, count($seeds), 'new', count($new-friends) })
    )
    let $next-gen := $gen - 1
    (: transitive-closure-filter does the map:put, so always call it :)
    let $new-friends := sem:transitive-closure-filter(
      $m, $new-friends, $filters, $next-gen)
    let $d := (
      if (not($sem:DEBUG)) then ()
      else xdmp:log(text {
          'transitive-closure gen',
          $gen, count($seeds), 'filtered', count($new-friends) })
    )
    where exists($new-friends) and $next-gen gt 0
    return sem:transitive-closure(
      $m, $new-friends, $next-gen, $relation, $direction, $filters)
  )
};

declare function sem:serialize(
  $m as map:map, $max-gen as xs:integer)
 as item()+
{
  let $keys := map:keys($m)
  let $keys-count := count($keys)
  let $d := (
    if (not($sem:DEBUG)) then ()
    else xdmp:log(text { 'serialize', $max-gen, $keys-count })
  )
  return (
    $keys-count,
    for $k in $keys
    let $gen := $max-gen - map:get($m, $k)
    order by $gen descending, $k
    return text { $gen, $k }
  ),
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text { 'serialize end', $max-gen })
};

declare function sem:object-predicate-join(
  $o as xs:string*,
  $p as xs:string* )
 as element(sem:join)?
{
  if (empty($p) and empty($o)) then ()
  else element sem:join {
    for $i in $p return element sem:p { $i },
    for $i in $o return element sem:o { $i } }
};

declare function sem:predicate-join(
  $p as xs:string* )
 as element(sem:join)?
{
  if (empty($p)) then ()
  else element sem:join {
    for $i in $p return element sem:p { $i } }
};

declare function sem:subject-predicate-join(
  $s as xs:string*,
  $p as xs:string* )
 as element(sem:join)?
{
  if (empty($s) and empty($p)) then ()
  else element sem:join {
    for $i in $s return element sem:s { $i },
    for $i in $p return element sem:p { $i } }
};

declare function sem:type-join(
  $type as xs:string+)
as element(sem:join)
{
  sem:object-predicate-join($type, $sem:P-RDF-TYPE)
};

(: substitute function calls for flwor, to maintain streaming :)
declare function sem:object-for-join(
  $joins as element(sem:join)+)
 as xs:string*
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text { 'sem:object-for-join', count($joins) })
  ,
  if (count($joins, 2) gt 1) then sem:object-for-join(
    sem:object-for-join($joins[1]),
    subsequence($joins, 2) )
  (: single join :)
  else if ($joins/sem:o) then sem:object-for-object-predicate(
      $joins/sem:o, $joins/sem:p)
  else if ($joins/sem:s) then sem:object-for-subject-predicate(
      $joins/sem:s, $joins/sem:p)
  else if ($joins/sem:select) then (
    if ($joins/sem:select/@type
      eq 'subject') then sem:object-for-subject-predicate(
      sem:select($joins/sem:select), $joins/sem:p)
    else if ($joins/sem:select/@type
      eq 'object') then sem:object-for-object-predicate(
      sem:select($joins/sem:select), $joins/sem:p)
    else error(
      (), 'SEM-UNEXPECTED', text {
        'select type must be subject or object' })
  )
  (: TODO handle other join cases? :)
  else error(
    (), 'SEM-UNEXPECTED',
    text { 'cannot join without object-predicate or subject-predicate' })
};

(: substitute function calls for flwor, to maintain streaming :)
declare function sem:object-for-join(
  $seeds as xs:string*,
  $joins as element(sem:join)* )
 as xs:string*
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text {
      'sem:object-for-join', count($seeds), count($joins) })
  ,
  if (empty($seeds) or empty($joins)) then $seeds
  else sem:object-for-join($seeds, $joins[1], subsequence($joins, 2))
};


declare private function sem:object-for-join(
  $seeds as xs:string*,
  $first as element(sem:join),
  $joins as element(sem:join)* )
 as xs:string*
{
  sem:object-for-join(
    $seeds, $first/sem:s, $first/sem:o, $first/sem:p, $joins)
};

declare private function sem:object-for-join(
  $seeds as xs:string*,
  $s as xs:string*,
  $o as xs:string*,
  $p as xs:string*,
  $joins as element(sem:join)* )
 as xs:string*
{
  sem:object-for-join(
    if ($o and $p) then sem:subject-by-subject-object-predicate(
      $seeds, $o, $p)
    (: seeds will be objects for the relation :)
    else if ($s and $p) then sem:object-by-subject-object-predicate(
      $s, $seeds, $p)
    (: TODO handle other join cases? :)
    else error(
      (), 'SEM-UNEXPECTED',
      text { 'cannot join without object-predicate or subject-predicate' })
    ,
    $joins
  )
};

(: substitute function calls for flwor, to maintain streaming :)
declare function sem:subject-for-join(
  $joins as element(sem:join)+)
 as xs:string*
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text { 'sem:subject-for-join', count($joins) })
  ,
  if (count($joins, 2) gt 1) then sem:subject-for-join(
    sem:subject-for-join($joins[1]),
    subsequence($joins, 2) )
  (: single join :)
  else if ($joins/sem:o) then sem:subject-for-object-predicate(
      $joins/sem:o, $joins/sem:p)
  else if ($joins/sem:s) then sem:subject-for-subject-predicate(
      $joins/sem:s, $joins/sem:p)
  else if ($joins/sem:select) then (
    if ($joins/sem:select/@type
      eq 'subject') then sem:subject-for-subject-predicate(
      sem:select($joins/sem:select), $joins/sem:p)
    else if ($joins/sem:select/@type
      eq 'object') then sem:subject-for-object-predicate(
      sem:select($joins/sem:select), $joins/sem:p)
    else error(
      (), 'SEM-UNEXPECTED', text {
        'select type must be subject or object' })
  )
  (: TODO handle other join cases? :)
  else error(
    (), 'SEM-UNEXPECTED',
    text { 'cannot join without object-predicate or subject-predicate' })
};

(: substitute function calls for flwor, to maintain streaming :)
declare function sem:subject-for-join(
  $seeds as xs:string*,
  $joins as element(sem:join)* )
 as xs:string*
{
  if (not($sem:DEBUG)) then ()
  else xdmp:log(text {
      'sem:subject-for-join', count($seeds), count($joins) })
  ,
  if (empty($seeds) or empty($joins)) then $seeds
  else sem:subject-for-join($seeds, $joins[1], subsequence($joins, 2))
};


declare private function sem:subject-for-join(
  $seeds as xs:string*,
  $first as element(sem:join),
  $joins as element(sem:join)* )
 as xs:string*
{
  sem:subject-for-join(
    $seeds, $first/sem:s, $first/sem:o, $first/sem:p, $joins)
};

declare private function sem:subject-for-join(
  $seeds as xs:string*,
  $s as xs:string*,
  $o as xs:string*,
  $p as xs:string*,
  $joins as element(sem:join)* )
 as xs:string*
{
  sem:subject-for-join(
    if ($o and $p) then sem:subject-by-subject-object-predicate(
      $seeds, $o, $p)
    (: seeds will be objects for the relation :)
    else if ($s and $p) then sem:object-by-subject-object-predicate(
      $s, $seeds, $p)
    (: TODO handle other join cases? :)
    else error(
      (), 'SEM-UNEXPECTED',
      text { 'cannot join without object-predicate or subject-predicate' })
    ,
    $joins
  )
};

declare function sem:owl-on-property(
  $prop as xs:string*)
as xs:string*
{
  if (empty($prop)) then () else
  sem:subject-for-object-predicate($prop, $sem:P-OWL-ON-PROPERTY)
};

declare function sem:owl-subclasses(
  $class as xs:string*)
as xs:string*
{
  if (empty($class)) then () else
  sem:rdf-subclasses((
      sem:subject-for-object-predicate(
        sem:subject-for-object-predicate($class, $sem:P-RDF-FIRST),
        $sem:P-OWL-INTERSECTION ),
      sem:owl-subclasses-implicit($class) ))
};

declare private function sem:owl-subclasses-implicit(
  $class as xs:string*)
as xs:string*
{
  $class,
  let $inter := sem:object-for-subject-predicate(
    $class, $sem:P-OWL-INTERSECTION)
  let $req-1 := sem:object-for-subject-predicate($inter, $sem:P-RDF-FIRST)
  let $req-2 := sem:object-for-subject-predicate($inter, $sem:P-RDF-REST)
  let $req-2 := sem:subject-for-join(
    $req-2, (sem:object-predicate-join($sem:O-RDF-NIL, $sem:P-RDF-REST)) )
  let $req-2 := sem:object-for-subject-predicate($req-2, $sem:P-RDF-FIRST)
  let $req-2 := sem:object-for-subject-predicate(
    $req-2, $sem:P-OWL-ON-PROPERTY)
  let $req-2 := sem:rdf-subclasses(sem:owl-on-property($req-2))
  return sem:subject-for-join(
    $req-2,
    (sem:object-predicate-join($req-1, $sem:P-RDF-SUBCLASS)) )
};

declare function sem:rdf-subclasses(
  $class as xs:string*)
as xs:string*
{
  if (empty($class)) then () else
  let $sub := sem:subject-for-object-predicate($class, $sem:P-RDF-SUBCLASS)
  return (
    (: time to stop? :)
    if (empty($sub)) then $class else (
      $class,
      sem:rdf-subclasses($sub)
    )
  )
};

declare function sem:rdf-subproperties(
  $prop as xs:string*)
as xs:string*
{
  if (empty($prop)) then () else
  let $sub := sem:subject-for-object-predicate($prop, $sem:P-RDF-SUBPROPERTY)
  return (
    (: time to stop? :)
    if (empty($sub)) then $prop else (
      $prop,
      sem:rdf-subproperties($sub)
    )
  )
};

declare function sem:relate(
  $a as xs:QName,
  $b as xs:QName,
  $a-seed as xs:string*,
  $b-seed as xs:string*,
  $join as element(sem:join)* )
as map:map
{
  sem:relate(
    $a, $b,
    sem:relate-query($a, $b, $a-seed, $b-seed, $join),
    map:map()
  )
};

declare private function sem:relate-query(
  $a as xs:QName,
  $b as xs:QName,
  $a-seed as xs:string*,
  $b-seed as xs:string*,
  $join as element(sem:join)* )
as cts:query
{
  cts:and-query(
    (if (empty($a-seed)) then () else sem:rq($a, $a-seed),
      if (empty($b-seed)) then () else sem:rq($b, $b-seed),
      for $j in $join
      return (
        if ($j/sem:o and $j/sem:p) then error((), 'UNIMPLEMENTED')
        else if ($j/sem:s and $j/sem:p) then error((), 'UNIMPLEMENTED')
        else if ($j/sem:p) then sem:pq($j/sem:p)
        else error((), 'SEM-UNEXPECTED')
        ) ) )
};

declare private function sem:relate(
  $a as xs:QName, $b as xs:QName,
  $query as cts:query,
  $m as map:map)
as map:map
{
  sem:relate(
    $m, cts:element-value-co-occurrences(
      $a, $b, $sem:LEXICON-OPTIONS, $query) ),
  if (not($sem:DEBUG)) then () else xdmp:log(
    text { 'sem:relate', count(map:keys($m)) } ),
  $m
};

declare private function sem:relate(
  $m as map:map, $co as element(cts:co-occurrence) )
as empty-sequence()
{
  map:put($m, $co/cts:value[1], $co/cts:value[2]/string())
};

declare private function sem:relate-join(
  $a as xs:QName, $b as xs:QName,
  $query as cts:query )
as element(cts:co-occurrence)*
{
  cts:element-value-co-occurrences(
    $a, $b, $sem:LEXICON-OPTIONS, $query)
};

declare function sem:relate-join(
  $a as xs:QName,
  $b as xs:QName,
  $a-seed as xs:string*,
  $b-seed as xs:string*,
  $join as element(sem:join)* )
as element(cts:co-occurrence)*
{
  sem:relate-join(
    $a, $b,
    sem:relate-query($a, $b, $a-seed, $b-seed, $join)
  )
};

declare function sem:uri-for-tuple(
  $s as xs:string,
  $p as xs:string,
  $o as xs:string,
  $c as xs:string?)
as xs:string
{
  (: build a deterministic uri for a triple or quad :)
  xdmp:integer-to-hex(
    xdmp:hash64(
      string-join(($s, $p, $o, $c), '|') ) )
};

declare function sem:uri-for-tuple(
  $t as element(t) )
as xs:string
{
  sem:uri-for-tuple($t/s, $t/p, $t/o, $t/c)
};

declare function sem:tuple(
  $s as xs:string,
  $p as xs:string,
  $o as xs:string,
  $c as xs:string?)
as element(t)
{
  element t {
    element s {
      attribute h { xdmp:hash64($s) },
      $s },
    element p {
      attribute h { xdmp:hash64($p) },
      $p },
    element o {
      attribute h { xdmp:hash64($o) },
      $o },
    if (empty($c)) then ()
    else element c {
      attribute h { xdmp:hash64($c) },
      $c }
  }
};

declare function sem:tuple-insert(
  $s as xs:string,
  $p as xs:string,
  $o as xs:string,
  $c as xs:string?)
as empty-sequence()
{
  xdmp:document-insert(
    sem:uri-for-tuple($s, $p, $o, $c),
    sem:tuple($s, $p, $o, $c) )
};

declare function sem:tuple-insert(
  $t as element(t))
as empty-sequence()
{
  xdmp:document-insert(
    sem:uri-for-tuple($t/s, $t/p, $t/o, $t/c),
    sem:tuple($t/s, $t/p, $t/o, $t/c) )
};

declare function sem:tuples-for-query(
  $q as cts:query )
as element(t)*
{
  cts:search(/t, $q, 'unfiltered')
};

declare function sem:tuples-for-predicate(
  $p as xs:string+ )
as element(t)*
{
  sem:tuples-for-query(sem:pq($p))
};

declare function sem:select(
  $s as element(sem:select))
{
  sem:select($s/@type, $s/sem:join)
};

declare function sem:select(
  $type as xs:string,
  $join as element(sem:join)+)
{
  if ($type eq 'subject') then sem:subject-for-join($join)
  else if ($type eq 'object') then sem:object-for-join($join)
  else error((), 'SEM-UNEXPECTED', text {
      'select must have type subject or object, not',
      xdmp:describe($type) })
};

(: semantic.xqy :)

(: --- enhancement ---  :)

(: shortcut for sem:rq :)
declare  function sem:query-s(
  $s as xs:string*)
 as cts:query?
{
  if (empty($s)) 
  then sem:rq($sem:QN-S, '')
  else sem:rq($sem:QN-S, $s)
};

(: shortcut for sem:rq :)
declare  function sem:query-o(
  $o as xs:string*)
 as cts:query?
{
  if (empty($o)) 
  then sem:rq($sem:QN-O, '')
  else sem:rq($sem:QN-O, $o)
};
(: with sub-property inference :)
(:  sem:rq($sem:QN-O, sem:rdf-subclasses($o) ) :)
(:  sem:rq($sem:QN-O, sem:owl-subclasses($o))  :)


(: shortcut for sem:pq :)
declare function sem:query-p(
  $p as xs:string*)
 as cts:query?
{
  if (empty($p)) 
  then sem:pq('')
  else sem:pq($p)
};

(: query c :)
declare function sem:query-c(
  $c as xs:string*)
 as cts:query?
{
  if (empty($c)) 
  then sem:hq($sem:QN-C, xdmp:hash64('')) 
  else sem:hq($sem:QN-C, xdmp:hash64($c))
};



(: with sub-property inference :)
(:  sem:pq(sem:list-direct-subproperties($p))  :)

(: compute inverse :)
declare variable $sem:P-OWL-INVERSE :=
'http://www.w3.org/2002/07/owl#inverseOf'
;

declare function sem:owl-inverse(
  $p as xs:string*)
as xs:string*
{
  if (empty($p)) then () else
  sem:merge-sequence(
	sem:subject-for-object-predicate($p, $sem:P-OWL-INVERSE),
    sem:object-for-subject-predicate($p, $sem:P-OWL-INVERSE)
  )
};

(: compute transitive closure :)
declare function sem:tc-s($seeds as xs:string* , $p as xs:string*)
   as xs:string* {
      let $next := sem:object-for-subject-predicate($seeds, $p)
	  return
	  if ( $next ) then ($seeds , sem:tc-s($next, $p) )
	  else ($seeds)
}; 

(: compute transitive closure :)
declare function sem:tc-o($seeds as xs:string* , $p as xs:string*)
   as xs:string* {
      let $next := sem:subject-for-object-predicate($seeds, $p)
      return 
	    if ( $next ) then ($seeds , sem:tc-o($next, $p))
	    else ($seeds)
}; 


(: evaluate a list of queries :)
declare function sem:ev1(
  $qn as xs:QName, 
  $query as cts:query*)
as xs:string*
{
	if (empty($query))
	then ()
	else sem:ev($qn, cts:and-query( $query) )
};

(: evaluate a list of queries :)
declare function sem:evT(
  $query as cts:query*)
as element(t)*
{
	if (empty($query))
	then ()
	else sem:tuples-for-query(cts:and-query( $query) )
};

declare function sem:merge-sequence(
  $seq1 as item()*,
  $seq2 as item()*)
as item()*
{
  if (empty($seq1)) then $seq2
  else if (empty($seq2)) then $seq1
  else
  for $x in	$seq1
  for $y in $seq2
  return ($x, $y)
};

(: shortcut for sem:relate-join :)
declare function sem:ev2(
  $a as xs:QName, 
  $b as xs:QName,
  $query as cts:query )
as element(cts:co-occurrence)*
{
  sem:relate-join ( $a, $b, $query)
};

(: merge bindings with one variable result, zero pre-existing variable :)
declare function sem:merge_1_0(
  $bindings as element(binding)*,
  $data as xs:string*,
  $co_field1_name as xs:string
 )
as element(binding)*
 {
  if (empty($data)) then error((),'empty results')
  else 
  if (empty($bindings)) then (
    for $d in $data
    return ( element binding 
      {element {$co_field1_name} {$d} }
    )
  )
  else
    for $d in $data
    for $t in $bindings
    return ( element binding 
      {$t/*, element {$co_field1_name} {$d} }
    )
   
 };

(: merge bindings with one variable result, one pre-existing variable :)
declare function sem:merge_1_1(
  $bindings as element(binding)+,
  $data as xs:string*,
  $co_field1_name as xs:string
 )
as element(binding)*
 {
  if (empty($data)) then error((),'empty results')
  else 
  if (empty($bindings)) then  error((),'empty results')
  else
    for $d in $data
    for $t in $bindings
    where ($t/node()[name()=$co_field1_name]/string() = $d)
     return ( element binding 
      {$t/*}
    )
 };

 
(: merge bindings with two variable co-existing result, no pre-existing variable :)
declare function sem:merge_2_0(
  $bindings as element(binding)*,
  $co as element(cts:co-occurrence)*,
  $co_field1_name as xs:string,
  $co_field2_name as xs:string
 )
as element(binding)*
 {
  if (empty($co)) then  error((),'empty results')
  else 
  if (empty($bindings)) then (
  for $c in $co
  return ( element binding 
    {element {$co_field1_name} {$c/cts:value[1]/string()} ,
    element {$co_field2_name} {$c/cts:value[2]/string()} }
   )
  )
  else
  for $c in $co
  for $t in $bindings
  return ( element binding 
    {$t/*, element {$co_field1_name} {$c/cts:value[1]/string()} ,
    element {$co_field2_name} {$c/cts:value[2]/string()} }
   )
 };
 
 
(: merge bindings with two variable co-existing result, one pre-existing variable :)
 declare function sem:merge_2_1(
  $bindings as element(binding)*,
  $co as element(cts:co-occurrence)*,
  $binding_field_join_name as xs:string,
  $co_field_join_pos as xs:int,
  $co_field_value_name as xs:string,
  $co_field_value_pos as xs:int
  )
  as element(binding)*
 {
  if (empty($co)) then  error((),'empty results')
  else 
  for $t in $bindings
  for $c in $co 
  where ($t/node()[name()=$binding_field_join_name]/string() = $c/cts:value[$co_field_join_pos]/string())
  return ( element binding 
	{$t/*,
    element {$co_field_value_name} {$c/cts:value[$co_field_value_pos]/string()} }
   )
 };
 
(: merge bindings with two variable co-existing result, two pre-existing variable :)
 declare function sem:merge_2_2(
  $bindings as element(binding)*,
  $co as element(cts:co-occurrence)*,
  $co_field1_name as xs:string,
  $co_field2_name as xs:string
  )
  as element(binding)*
 {
  if (empty($co)) then  error((),'empty results')
  else 
  for $t in $bindings
  for $c in $co 
  where (($t/node()[name()=$co_field1_name]/string() = $c/cts:value[1]/string()) and ($t/node()[name()=$co_field2_name]/string() = $c/cts:value[2]/string()))
  return ( element binding 
	{$t/*}
   )
 };
 
(: list direct sub-classes :) 
 declare function sem:list-direct-subclasses(
  $class as xs:string*)
as xs:string*
{
  if (empty($class)) then () else
  let $sub := sem:subject-for-object-predicate($class, $sem:P-RDF-SUBCLASS)
  return (
    (: time to stop? :)
    if (empty($sub)) then $class else (
      $class,
      $sub
    )
  )
};

(: list direct sub-property:) 
declare function sem:list-direct-subproperties(
  $prop as xs:string*)
as xs:string*
{
  if (empty($prop)) then () else
  let $sub := sem:subject-for-object-predicate($prop, $sem:P-RDF-SUBPROPERTY)
  return (
    (: time to stop? :)
    if (empty($sub)) then $prop else (
      $prop,
     $sub
    )
  )
};


(: create a quad :) 
declare function sem:quad(
  $s as xs:string,
  $s_type as xs:string,
  $p as xs:string,
  $p_type as xs:string,
  $o as xs:string,
  $o_type as xs:string,
  $c as xs:string?)
as element(t)
{
  element t {
    element s {
      attribute h { xdmp:hash64($s) },
      attribute type { $s_type },
      $s },
    element p {
      attribute h { xdmp:hash64($p) },
      attribute type { $p_type },
      $p },
    element o {
      attribute h { xdmp:hash64($o) },
      attribute type { $o_type },
      $o },
    if (empty($c)) 
	then ()
    else element c {
      attribute h { xdmp:hash64($c) },
      attribute type { 'uri' },
      $c }
  }
};

declare function sem:quad-insert(
  $s as xs:string,
  $s_type as xs:string,
  $p as xs:string,
  $p_type as xs:string,
  $o as xs:string,
  $o_type as xs:string,
  $c as xs:string?)
as empty-sequence()
{
  xdmp:document-insert(
    sem:uri-for-tuple($s, $p, $o, $c),
    sem:quad($s, $s_type, $p, $p_type, $o, $o_type, $c) )
};

(: sameAs support  :)
declare function sem:list-sameas(
  $list as xs:string*)
as xs:string*
{
  if (empty($list) ) then () else
      (
		sem:subject-for-object-predicate( $list, 'http://www.w3.org/2002/07/owl#sameAs'),
		sem:object-for-subject-predicate( $list, 'http://www.w3.org/2002/07/owl#sameAs')
	  )
  
};


(:------------------------------------------------:)
(:  Forward-Chaining Inference  :)
(:------------------------------------------------:)

(:  Forward-Chaining Inference -- general :)
declare function sem:inf-tuple-insert($m as map:map)
as  empty-sequence()
{
  for $key in map:keys($m)
  return  xdmp:document-insert($key, map:get($m, $key))
};

declare function sem:inf-owl2rl(){
  let $m := map:map()
  let $query := ( 
   sem:inf-owl2rl-eq-sym($m),
   sem:inf-owl2rl-eq-trans($m),
   sem:inf-owl2rl-eq-rep-s($m),
   ()
  ) 
  let $cnt_new := map:count($m)
  let $cnt_original := count(/t) 
  let $insert := sem:inf-tuple-insert($m) 
  let $cnt_inserted := count(/t) - $cnt_original
  let $ret := (
   if ($cnt_inserted>0)
   then text { 'sem:inf-owl2rl -- triples to insert:', $cnt_new, '; triples inserted:', $cnt_inserted }
   else () )
  return $ret
};


(:  Forward-Chaining Inference -- rules :)

(: owl2rl | eq-sym | sameAs :)
declare function sem:inf-owl2rl-eq-sym($m as map:map)
as  empty-sequence()
{
  for  $t_x_y in sem:evT( sem:query-p( 'http://www.w3.org/2002/07/owl#sameAs' ) ) 
      , $x in $t_x_y/s/text()
      , $y in $t_x_y/o/text()
  where ($x != $y)
  return map:put(
      $m, 
      sem:uri-for-tuple($y, 'http://www.w3.org/2002/07/owl#sameAs', $x, ''),   
      sem:tuple($y, 'http://www.w3.org/2002/07/owl#sameAs', $x, '')) 
};
 


(: owl2rl | eq-trans | sameAs :)
declare function sem:inf-owl2rl-eq-trans($m as map:map)
as  empty-sequence()
{
  for  $t_x_y in sem:evT( sem:query-p( 'http://www.w3.org/2002/07/owl#sameAs' ) ) 
      , $x in $t_x_y/s/text()
      , $y in $t_x_y/o/text()
  for  $z in sem:ev1( $sem:QN-S, (sem:query-s( $y ), sem:query-p( 'http://www.w3.org/2002/07/owl#sameAs' ) )) 
  where ($x != $y) and ($y != $z)
  return map:put(
      $m, 
      sem:uri-for-tuple($x, 'http://www.w3.org/2002/07/owl#sameAs', $z, ''),   
      sem:tuple($x, 'http://www.w3.org/2002/07/owl#sameAs', $z, '')) 
};
 


(: owl2rl | eq-rep-s | sameAs :)
declare function sem:inf-owl2rl-eq-rep-s($m as map:map)
as  empty-sequence()
{
  for  $t_x_y in sem:evT( sem:query-p( 'http://www.w3.org/2002/07/owl#sameAs' ) ) 
      , $x in $t_x_y/s/text()
      , $y in $t_x_y/o/text()
  for  $t_p_o in sem:evT( sem:query-s( $x ) ) 
      , $p in $t_p_o/p/text()
      , $o in $t_p_o/o/text()
  where ($x != $y)
  return map:put(
      $m, 
      sem:uri-for-tuple($y, $p, $o, ''),   
      sem:tuple($y, $p, $o, '')) 
};
 

(:------------------------------------------------:)
(:  Set operators  :)
(:------------------------------------------------:)
declare function sem:setop-distinct-element($seq as element()*, $m as map:map) {
    for $e in $seq
    return map:put($m, $e,$e)  
};

declare function sem:setop-distinct-element($seq as element()*) {
  let $m := map:map()
  let $x := sem:setop-distinct-element($seq, $m)
  for $y in map:keys($m)
  return map:get($m,$y)
};

declare function sem:setop-intersect($m as map:map, $seq1 as element()*, $seq2 as element()*) {
    for $e1 in $seq1
    for $e2 in $seq2
    where deep-equal($e1,$e2)
    return map:put($m, $e1,$e1) 
};
 