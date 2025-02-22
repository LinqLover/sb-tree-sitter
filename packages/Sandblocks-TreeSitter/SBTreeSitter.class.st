Class {
	#name : #SBTreeSitter,
	#superclass : #ExternalLibrary,
	#instVars : [
		'currentString',
		'language'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTreeSitter class >> moduleName [

	^ 'tree-sitter'
]

{ #category : #'ffi languages' }
SBTreeSitter >> bash [

	<apicall: SBTSLanguageStruct* tree_sitter_bash () module: 'tree-sitter-bash'>
	^ SBTSLanguage
		tryPatchLibrary: 's4pu/tree-sitter-bash'
		name: 'bash'
		context: thisContext
		branch: 'flags'
		subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> c [

	<apicall: SBTSLanguageStruct* tree_sitter_c () module: 'tree-sitter-c'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-c' name: 'c' context: thisContext branch: 'master' subpath: ''
]

{ #category : #helper }
SBTreeSitter >> changedRangesFrom: anOldTree to: aNewTree [

	| lengthPtr rangesPtr ranges |
	lengthPtr := IntegerArray new: 1 withAll: 5.
	rangesPtr := self treeGetChangedRangesOld: anOldTree new: aNewTree outLength: lengthPtr.
	ranges := (0 to: lengthPtr first - 1) collect: [:offset | (SBTSFFIRange fromHandle: rangesPtr getHandle + (rangesPtr byteSize * offset)) asRange].
	rangesPtr free.
	^ ranges
]

{ #category : #'ffi languages' }
SBTreeSitter >> clojure [

	<apicall: SBTSLanguageStruct* tree_sitter_clojure () module: 'tree-sitter-clojure'>
	^ SBTSLanguage tryPatchLibrary: 'sogaiu/tree-sitter-clojure' name: 'clojure' context: thisContext branch: 'e57c569ae332ca365da623712ae1f50f84daeae2' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> cpp [

	<apicall: SBTSLanguageStruct* tree_sitter_cpp () module: 'tree-sitter-cpp'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-cpp' name: 'cpp' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> css [

	<apicall: SBTSLanguageStruct* tree_sitter_css () module: 'tree-sitter-css'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-css' name: 'css' context: thisContext branch: 'master' subpath: ''
]

{ #category : #ffi }
SBTreeSitter >> cursor: aCursor reset: aNode [

	<apicall: void ts_tree_cursor_reset (SBTSTreeCursor* SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorCopy: aCursor [

	<apicall: SBTSTreeCursor ts_tree_cursor_copy (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorCurrentFieldName: aCursor [

	<apicall: char* ts_tree_cursor_current_field_name (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorCurrentNode: aCursor [

	<apicall: SBTSNode ts_tree_cursor_current_node (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorDelete: aCursor [

	<apicall: void ts_tree_cursor_delete (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorGotoFirstChild: aCursor [

	<apicall: bool ts_tree_cursor_goto_first_child (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorGotoNextSibling: aCursor [

	<apicall: bool ts_tree_cursor_goto_next_sibling (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorGotoParent: aCursor [

	<apicall: bool ts_tree_cursor_goto_parent (SBTSTreeCursor*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> cursorNew: root [

	<apicall: SBTSTreeCursor ts_tree_cursor_new (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #helper }
SBTreeSitter >> externalCallFailed [

	^ ExternalFunction getLastError = 15
		ifTrue: [ | path |
			Smalltalk platformName = 'Mac OS' ifTrue: [
				thisContext sender method externalLibraryName: 'libtree-sitter.dylib'.
				^ thisContext sender method externalLibraryFunction invokeWithArguments: thisContext sender arguments].
			
			path := SBTSLanguage fetchTreeSitter fullName.
			self class methodDict valuesDo: [:method | " only change for those that don't have an explicit module (lang-specific) "
			method methodReference category ~= 'ffi languages' ifTrue: [method externalLibraryName: path]].
			thisContext sender method externalLibraryFunction invokeWithArguments: thisContext sender arguments]
		ifFalse: [super externalCallFailed]
]

{ #category : #helper }
SBTreeSitter >> fetchLibrary: aGithubString language: language andRetry: aBlock [

	SBToggledCode comment: '' active: 1 do: {
		[ | path filename |
			filename := 'tree-sitter-{1}.so' format: {language}.
			path := (MCFetchGithubRepository new
				projectPath: aGithubString
				projectVersion: 'master'
				repoPath: nil) directory.
			OSProcess waitForCommand: ('cd {1}; npx -p tree-sitter-cli tree-sitter generate' format: {path fullName}).
			OSProcess waitForCommand: ('cd {1}; gcc -shared -fPIC -o {2} src/parser.c -I./src/' format: {path fullName. filename}).
			path / filename copyHere: FileDirectory default / filename.
			aBlock value].
		[ | zip |
			zip := WebClient httpGet: 'https://api.github.com/repos/', aGithubString, '/zipball/master'.
			ZipArchive new
				readFrom: zip getContent readStream binary;
				extractAllTo: (FileDirectory default / 'tree-sitter-languages') assureExistence
					informing: nil
					overwrite: false]}
]

{ #category : #'ffi languages' }
SBTreeSitter >> gdscript [

	<apicall: SBTSLanguageStruct* tree_sitter_gdscript () module: 'tree-sitter-gdscript'>
	^ SBTSLanguage tryPatchLibrary: 'tom95/tree-sitter-gdscript' name: 'gdscript' context: thisContext branch: 'main' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> glsl [

	<apicall: SBTSLanguageStruct* tree_sitter_glsl () module: 'tree-sitter-glsl'>
	^ SBTSLanguage tryPatchLibrary: 'theHamsta/tree-sitter-glsl' name: 'glsl' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> html [

	<apicall: SBTSLanguageStruct* tree_sitter_html () module: 'tree-sitter-html'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-html' name: 'html' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> java [

	<apicall: SBTSLanguageStruct* tree_sitter_java () module: 'tree-sitter-java'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-java' name: 'java' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> javascript [

	<apicall: SBTSLanguageStruct* tree_sitter_javascript () module: 'tree-sitter-javascript'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-javascript' name: 'javascript' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> json [

	<apicall: SBTSLanguageStruct* tree_sitter_json () module: 'tree-sitter-json'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-json' name: 'json' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> kotlin [

	<apicall: SBTSLanguageStruct* tree_sitter_kotlin () module: 'tree-sitter-kotlin'>
	^ SBTSLanguage tryPatchLibrary: 'fwcd/tree-sitter-kotlin' name: 'kotlin' context: thisContext branch: 'master' subpath: ''
]

{ #category : #accessing }
SBTreeSitter >> language [

	^ language
]

{ #category : #ffi }
SBTreeSitter >> language: language symbolForName: aString length: aNumber isNamed: aBoolean [

	<apicall: uint16_t ts_language_symbol_for_name (void* char* uint32_t bool)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> languageVersion: language [

	<apicall: uint32_t ts_language_version (SBTSLanguageStruct*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> node: aNode childByFieldName: aString length: aNumber [

	<apicall: SBTSNode ts_node_child_by_field_name (SBTSNode char* uint32_t)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeChild: aNode at: aNumber [

	<apicall: SBTSNode ts_node_child (SBTSNode, uint32_t)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeChildCount: aNode [

	<apicall: uint32_t ts_node_child_count (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeEdit: aNode edit: anEdit [

	<apicall: void ts_node_edit (SBTSNode *, SBTSInputEdit *)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeEndByte: aNode [

	<apicall: uint32_t ts_node_end_byte (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeEndPoint: aNode [

	<apicall: SBTSPoint ts_node_end_point (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeHasError: aNode [

	<apicall: bool ts_node_has_error (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeIsMissing: aNode [

	<apicall: bool ts_node_is_missing (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeIsNamed: aNode [

	<apicall: bool ts_node_is_named (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeIsNull: aNode [

	<apicall: bool ts_node_is_null (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeNextSibling: aNode [

	<apicall: SBTSNode ts_node_next_sibling (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeParent: aNode [

	<apicall: SBTSNode ts_node_parent (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodePrevSibling: aNode [

	<apicall: SBTSNode ts_node_prev_sibling (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodePrivAlias: aNode [

	<apicall: uint16_t ts_node__alias (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeStartByte: aNode [

	<apicall: uint32_t ts_node_start_byte (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeStartPoint: aNode [

	<apicall: SBTSPoint ts_node_start_point (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeString: aNode [

	<apicall: char* ts_node_string (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeSymbol: aNode [

	<apicall: uint16_t ts_node_symbol (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> nodeType: aNode [

	<apicall: char* ts_node_type (SBTSNode)>
	^ self externalCallFailed
]

{ #category : #helper }
SBTreeSitter >> parseAsCursor: aString language: aSymbol do: aBlock [

	^ self parseAsCursor: aString language: aSymbol oldTree: nil do: aBlock
]

{ #category : #helper }
SBTreeSitter >> parseAsCursor: aString language: aSymbol oldTree: aTree do: aBlock [

	| parser root tree cursor wasFreed |
	wasFreed := false.
	currentString := aString withUnixLineEndings utf8Encoded.
	language := self perform: aSymbol asSymbol.
	
	^ [
		parser := self parserNew.
		self parser: parser setLanguage: language.
		
		tree := self parser: parser old: aTree parseString: currentString length: currentString size.
		tree isNull ifTrue: [self error: 'tree failed to load, incompatible language version?'].
		
		root := self treeRootNode: tree.
		SBToggledCode
			comment: ''
			active: 0
			do: {[(self nodeHasError: root) ifTrue: [^ SBTSSyntaxError signal]]}.
		cursor := SBTSNodeCursor new on: root library: self.
		
		aBlock cull: cursor cull: tree] ensure: [
		" there were problems with double-free when debugging "
		wasFreed ifFalse: [
			wasFreed := true.
			SBToggledCode comment: '' active: 0 do: {
				[
					(cursor notNil and: ["we can't check for cursor isNull because it is stack-allocated
use this check instead as a best-guess to prevent crashes after a debugger popped up"
					parser isNull not]) ifTrue: [self cursorDelete: cursor]]}.
			(parser notNil and: [parser isNull not]) ifTrue: [self parserDelete: parser]]]
]

{ #category : #ffi }
SBTreeSitter >> parser: aParserPointer old: aTreePointer parseString: aString length: aNumber [

	<apicall: void* ts_parser_parse_string (void* void* char* uint32_t)> 
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> parser: aParserPointer setLanguage: aLanguagePointer [

	<apicall: void ts_parser_set_language (void* SBTSLanguageStruct*)> 
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> parserDelete: aCursor [

	<apicall: void ts_parser_delete (void*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> parserNew [

	<apicall: void* ts_parser_new ()> 
	^ self externalCallFailed
]

{ #category : #helper }
SBTreeSitter >> printTree: cursor [

	| indent visitedChildren |
	indent := 0.
	visitedChildren := false.
	[ | display |
		display := (self nodeIsMissing: cursor node)
			ifTrue: ['MISSING']
			ifFalse: [cursor type].
		visitedChildren
			ifTrue: [
				cursor gotoNextSibling ifTrue: [visitedChildren := false] ifFalse: [
					cursor gotoParent
						ifTrue: [
							visitedChildren := true.
							indent := indent - 1]
						ifFalse: [^ self]]]
			ifFalse: [
				Transcript showln: display.
				cursor gotoFirstChild
					ifTrue: [
						indent := indent + 1.
						visitedChildren := false]
					ifFalse: [visitedChildren := true]]] repeat
]

{ #category : #helper }
SBTreeSitter >> printTreeFrom: aCursor depth: aNumber on: aStream [

	aNumber timesRepeat: [aStream nextPut: Character tab].
	aStream
		nextPutAll: ((self nodeIsMissing: aCursor node)
			ifTrue: ['MISSING']
			ifFalse: [aCursor type]);
		cr.
	aCursor gotoFirstChild ifTrue: [
		[self printTreeFrom: aCursor depth: aNumber + 1 on: aStream] doWhileFalse: [aCursor gotoNextSibling].
		aCursor gotoParent]
]

{ #category : #helper }
SBTreeSitter >> printTreeRaw: cursor [

	| indent visitedChildren |
	indent := 0.
	visitedChildren := false.
	[ | display |
		display := (self nodeIsMissing: (self cursorCurrentNode: cursor))
			ifTrue: ['MISSING']
			ifFalse: [self nodeType: (self cursorCurrentNode: cursor)].
		visitedChildren
			ifTrue: [
				(self cursorGotoNextSibling: cursor)
					ifTrue: [visitedChildren := false]
					ifFalse: [
						(self cursorGotoParent: cursor)
							ifTrue: [
								visitedChildren := true.
								indent := indent - 1]
							ifFalse: [^ self]]]
			ifFalse: [
				Transcript showln: display.
				(self cursorGotoFirstChild: cursor)
					ifTrue: [
						indent := indent + 1.
						visitedChildren := false]
					ifFalse: [visitedChildren := true]]] repeat
]

{ #category : #'ffi languages' }
SBTreeSitter >> prisma [

	<apicall: SBTSLanguageStruct* tree_sitter_prisma () module: 'tree-sitter-prisma'>
	^ SBTSLanguage tryPatchLibrary: 'victorhqc/tree-sitter-prisma' name: 'prisma' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> python [

	<apicall: SBTSLanguageStruct* tree_sitter_python () module: 'tree-sitter-python'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-python' name: 'python' context: thisContext branch: '24b530ca158d2782ea9046e756057a412e16b52f' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> regex [

	<apicall: SBTSLanguageStruct* tree_sitter_regex () module: 'tree-sitter-regex'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-regex' name: 'regex' context: thisContext branch: '3041aa3472d16fd94c6a9e15b741dbfecd9b714e' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> ruby [

	<apicall: SBTSLanguageStruct* tree_sitter_ruby () module: 'tree-sitter-ruby'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-ruby' name: 'ruby' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> rust [

	<apicall: SBTSLanguageStruct* tree_sitter_rust () module: 'tree-sitter-rust'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-rust' name: 'rust' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> sexp [

	<apicall: SBTSLanguageStruct* tree_sitter_sexp () module: 'tree-sitter-sexp'>
	^ SBTSLanguage tryPatchLibrary: 'AbstractMachinesLab/tree-sitter-sexp' name: 'sexp' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> smalltalk [

	<apicall: SBTSLanguageStruct* tree_sitter_smalltalk () module: 'tree-sitter-smalltalk'>
	^ SBTSLanguage tryPatchLibrary: 'tom95/tree-sitter-smalltalk' name: 'smalltalk' context: thisContext branch: 'main' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> sql [

	<apicall: SBTSLanguageStruct* tree_sitter_sql () module: 'tree-sitter-sql'>
	^ SBTSLanguage tryPatchLibrary: 'DerekStride/tree-sitter-sql' name: 'sql' context: thisContext  branch: 'main' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> supercollider [

	<apicall: SBTSLanguageStruct* tree_sitter_supercollider () module: 'tree-sitter-supercollider'>
	^ SBTSLanguage tryPatchLibrary: 'madskjeldgaard/tree-sitter-supercollider' name: 'supercollider' context: thisContext branch: 'main' subpath: ''
]

{ #category : #helper }
SBTreeSitter >> textBetween: aNode and: anEndNode [

	^ self
		textBetweenIndex: (aNode
			ifNil: [ | parent |
				self assert: anEndNode notNil.
				parent := self nodeParent: anEndNode.
				
				" the root (node without a parent) starts after all whitespace, so special-case this "
				((self nodeIsNull: parent) or: [self nodeIsNull: (self nodeParent: parent)])
					ifTrue: [1]
					ifFalse: [(self nodeStartByte: parent) + 1 max: 1]]
			ifNotNil: [(self nodeEndByte: aNode) + 1])
		and: (anEndNode
			ifNil: [self nodeEndByte: (self nodeParent: aNode)]
			ifNotNil: [self nodeStartByte: anEndNode])
]

{ #category : #helper }
SBTreeSitter >> textBetweenIndex: aNumber and: anotherNumber [

	^ (currentString copyFrom: aNumber to: anotherNumber) utf8Decoded
]

{ #category : #helper }
SBTreeSitter >> textForNode: aNode [

	self assert: (aNode isNull not and: [aNode tree isNull not]).
	^ (currentString copyFrom: (self nodeStartByte: aNode) + 1 to: (self nodeEndByte: aNode)) utf8Decoded
]

{ #category : #'ffi languages' }
SBTreeSitter >> tlaplus [

	<apicall: SBTSLanguageStruct* tree_sitter_tlaplus () module: 'tree-sitter-tlaplus'>
	^ SBTSLanguage tryPatchLibrary: 'tlaplus-community/tree-sitter-tlaplus' name: 'tlaplus' context: thisContext branch: 'main' subpath: ''
]

{ #category : #ffi }
SBTreeSitter >> treeEdit: aTree edit: anEdit [ 

	<apicall: void 'ts_tree_edit' (void*, SBTSInputEdit*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> treeGetChangedRangesOld: aTree new: anothTree outLength: anIntPtr [ 

	<apicall: SBTSFFIRange* 'ts_tree_get_changed_ranges' (void*, void*, uint32_t*)>
	^ self externalCallFailed
]

{ #category : #ffi }
SBTreeSitter >> treeRootNode: aTree [

	<apicall: SBTSNode ts_tree_root_node (void*)>
	^ self externalCallFailed
]

{ #category : #'ffi languages' }
SBTreeSitter >> tsq [

	<apicall: SBTSLanguageStruct* tree_sitter_tsq () module: 'tree-sitter-tsq'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-tsq' name: 'tsq' context: thisContext branch: 'main' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> tsx [

	<apicall: SBTSLanguageStruct* tree_sitter_tsx () module: 'tree-sitter-tsx'>
	^ SBTSLanguage tryPatchLibrary: 'tom95/tree-sitter-typescript' name: 'tsx' context: thisContext branch: 'ternary-range-200' subpath: 'tsx'
]

{ #category : #'ffi languages' }
SBTreeSitter >> typescript [

	<apicall: SBTSLanguageStruct* tree_sitter_typescript () module: 'tree-sitter-typescript'>
	^ SBTSLanguage
		tryPatchLibrary: 'tom95/tree-sitter-typescript'
		name: 'typescript'
		context: thisContext
		branch: 'ternary-range-200'
		subpath: 'typescript'
]

{ #category : #'ffi languages' }
SBTreeSitter >> verilog [

	<apicall: SBTSLanguageStruct* tree_sitter_verilog () module: 'tree-sitter-verilog'>
	^ SBTSLanguage tryPatchLibrary: 'tree-sitter/tree-sitter-verilog' name: 'verilog' context: thisContext branch: 'master' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> vhdl [

	<apicall: SBTSLanguageStruct* tree_sitter_vhdl () module: 'tree-sitter-vhdl'>
	^ SBTSLanguage tryPatchLibrary: 'alemuller/tree-sitter-vhdl' name: 'vhdl' context: thisContext branch: 'main' subpath: ''
]

{ #category : #'ffi languages' }
SBTreeSitter >> wing [

	<apicall: SBTSLanguageStruct* tree_sitter_wing () module: 'tree-sitter-wing'>
	^ SBTSLanguage tryPatchLibrary: 'winglang/wing' name: 'wing' context: thisContext branch: 'main' subpath: 'libs/tree-sitter-wing'
]
