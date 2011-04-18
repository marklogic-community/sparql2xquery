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
  'any'
);

declare variable $sem:QN-S := xs:QName('s')
;

declare variable $sem:QN-O := xs:QName('o')
;

declare variable $sem:QN-P := xs:QName('p')
;

declare variable $sem:QN-C := xs:QName('c')
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

(: RangeQuery - returns a cts:element-range-query with the equal operator between $qn and $v :)
declare private function sem:rq(
  $qn as xs:QName+, $v as xs:string+)
as cts:query
{
  cts:element-range-query($qn, '=', $v)
};

(: EValuate - evaluates $query using cts:element-values and return qualified names specified in $qn from matching documents :)
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

(: PredicateQuery - returns a cts:query that matches predicates in $p :)
declare private function sem:pq(
  $p as xs:string+)
 as cts:query
{
  sem:rq($sem:QN-P, $p)
};

(: ObjectQuery - returns a cts:query that matches objects in $o :)
declare private function sem:oq(
  $o as xs:string+)
 as cts:query
{
  sem:rq($sem:QN-O, $o)
};

(: SubjectQuery - returns a cts:query that matches subjects in $s :)
declare private function sem:sq(
  $s as xs:string+)
 as cts:query
{
  sem:rq($sem:QN-S, $s)
};

(: ObjectPredicateQuery - returns a cts:query that matches objects in $o and predicates in $p:)
declare private function sem:opq(
  $o as xs:string+, $p as xs:string+)
 as cts:query
{
  cts:and-query((sem:rq($sem:QN-O, $o), sem:pq($p)))
};

(: SubjectPredicateQuery - returns a cts:query that matches subjects in $s and predicates in $p:)
declare private function sem:spq(
  $s as xs:string+, $p as xs:string+)
 as cts:query
{
  cts:and-query((sem:rq($sem:QN-S, $s), sem:pq($p)))
};

(: SubjectObjectPredicateQuery - returns a cts:query that matches subjects in $s, objects in $o, and predicates in $p:)
declare private function sem:sopq(
  $s as xs:string+, $o as xs:string+, $p as xs:string+)
 as cts:query
{
  cts:and-query((sem:rq($sem:QN-S, $s), sem:rq($sem:QN-O, $o), sem:pq($p)))
};

(: returns objects that matches predicates in $p :) 
declare function sem:object-for-predicate(
  $p as xs:string+)
as xs:string*
{
  if (empty($p)) then ()
  else sem:ev($sem:QN-O, sem:pq($p))
};

(: returns subjects that matches predicates in $p :) 
declare function sem:subject-for-predicate(
  $p as xs:string+)
as xs:string*
{
  if (empty($p)) then ()
  else sem:ev($sem:QN-S, sem:pq($p))
};

(: returns objects that matches subjects in $s, and predicates in $p :) 
declare function sem:object-for-object-predicate(
  $s as xs:string*, $p as xs:string+)
as xs:string*
{
  if (empty($s)) then ()
  else sem:ev($sem:QN-O, sem:opq($s, $p))
};

(: returns objects that matches subjects in $s and predicates in $p :)
declare function sem:object-for-subject-predicate(
  $s as xs:string*, $p as xs:string+)
as xs:string*
{
  if (empty($s)) then ()
  else sem:ev($sem:QN-O, sem:spq($s, $p))
};

(: returns subjects that matches objects in $o and predicates in $p :)
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

(: returns subjects that matches subjects in $s and predicates in $p :)
declare function sem:subject-for-subject-predicate(
   $s as xs:string*, $p as xs:string+)
as xs:string*
{
  if (empty($s)) then ()
  else sem:ev($sem:QN-S, sem:spq($s, $p))
};

(: returns objects that matches subjects in $s, objects in $o, and predicates in $p :)
declare function sem:object-by-subject-object-predicate(
  $s as xs:string+,
  $o as xs:string+,
  $p as xs:string+)
as xs:string*
{
  sem:ev($sem:QN-O, sem:sopq($s, $o, $p))
};

(: returns subjects that matches subjects in $s, objects in $o, and predicates in $p :)
declare function sem:subject-by-subject-object-predicate(
  $s as xs:string+,
  $o as xs:string+,
  $p as xs:string+)
as xs:string*
{
  sem:ev($sem:QN-S, sem:sopq($s, $o, $p))
};

(:
Take the list of $candidates, and filter them through $filters
(predicates).  Filters are applied as AND-conditions.  Candidates that
pass all filters are stored inside the map $m, with the key =
candidate, and value = $gen.
:)
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

(:
 Find the transitive-closure, starting from $seeds, using $relation as the predicate for traversing edges.  
 $m - This is used to store filtered results, where key = name, value = generation count
 $seeds     - This stores unfiltered results, and it's used recursively for finding the next generation of friends
 $gen       - An integer for counting generations
 $relation  - the predicate used for finding relationships
 $direction - If true, we traverse from subject to object.  If false, we traverse from object to subject
 $filter    - Used to filter out results.  Note that filter only essentially apply to the end result.  
              Friends that match the filter is still used to find the next generation of friends.
:)
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

(: 
returns a sem:join element that joins objects in $o and predicates in
$p, sem:join is used in *-for-join functions
:)
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

(: 
returns a sem:join element that joins predicates in $p, sem:join is
used in *-for-join functions
:)
declare function sem:predicate-join(
  $p as xs:string* )
 as element(sem:join)?
{
  if (empty($p)) then ()
  else element sem:join {
    for $i in $p return element sem:p { $i } }
};

(: 
returns a sem:join element that joins subjects in $s and predicates in
$p, sem:join is used in *-for-join functions
:)
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

(: 
returns a sem:join element that joins objects in $type and predicates
in $sem:P-RDF-TYPE
:)
declare function sem:type-join(
  $type as xs:string+)
as element(sem:join)
{
  sem:object-predicate-join($type, $sem:P-RDF-TYPE)
};

(: returns objects that matches the sem:join conditions in $joins :)
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

(: returns objects that matches the sem:join conditions in $joins, search is limited to triples that match elements in $seeds :)
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


(: 
returns objects that matches the sem:join conditions in $first, and
then $joins, search is limited to triples that match elements in
$seeds
:)
declare private function sem:object-for-join(
  $seeds as xs:string*,
  $first as element(sem:join),
  $joins as element(sem:join)* )
 as xs:string*
{
  sem:object-for-join(
    $seeds, $first/sem:s, $first/sem:o, $first/sem:p, $joins)
};

(: 
returns objects that matches subjects in $s, objects in $o, predicates
in $p, and then $joins.  Search is limited to triples that match
element in $seeds.

Note: It's unclear what is the correct return value if all 3 $s, $o,
and $p are specified.  But it seems that if $o and $p are specified,
then $seeds has to be a subject.  If $s and $p are specified, then
$seeds have to be an object.
:)
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

(: Same as object-for-join, except this returns objects instead of subjects :)
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

(: Same as object-for-join, except this returns objects instead of subjects :)
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


(: Same as object-for-join, except this returns objects instead of subjects :)
declare private function sem:subject-for-join(
  $seeds as xs:string*,
  $first as element(sem:join),
  $joins as element(sem:join)* )
 as xs:string*
{
  sem:subject-for-join(
    $seeds, $first/sem:s, $first/sem:o, $first/sem:p, $joins)
};

(: Same as object-for-join, except this returns objects instead of subjects :)
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
      $s },
    element p {
      $p },
    element o {
      $o },
    if (empty($c)) then ()
    else element c {
      $c }
  }
};

declare function sem:tuple-insert-as-property(
  $s as xs:string,
  $p as xs:string,
  $o as xs:string,
  $c as xs:string?)
as empty-sequence()
{
  xdmp:document-add-properties(
    sem:uri-for-tuple($s, $p, $o, $c),
    sem:tuple($s, $p, $o, $c)/* )
};

declare function sem:tuple-insert-as-property(
  $t as element(t))
as empty-sequence()
{
  xdmp:document-add-properties(
    sem:uri-for-tuple($t/s, $t/p, $t/o, $t/c),
    sem:tuple($t/s, $t/p, $t/o, $t/c)/* )
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

declare function sem:tuples-for-subject(
  $s as xs:string+ )
as element(t)*
{
  sem:tuples-for-query(sem:sq($s))
};

declare function sem:tuples-for-object(
  $o as xs:string+ )
as element(t)*
{
  sem:tuples-for-query(sem:oq($o))
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

(: source https://github.com/marklogic/semantic/raw/master/src/xquery/semantic.xqy :)