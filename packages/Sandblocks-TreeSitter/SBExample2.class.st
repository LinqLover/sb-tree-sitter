Class {
	#name : #SBExample2,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBExample2 >> artefactSaved: aMethodBlock [

	aMethodBlock = self containingArtefact ifTrue: [
		(self firstOwnerSuchThat: [:owner | owner isTSBlock and: [owner type = #'function_definition']]) ifNotNil: [:method | | name arguments |
			name := (method get: 'name') contents.
			arguments := self updateDuring: [(bindings at: 'arguments') sourceString].
			SBExecutionEnvironment value: self.
			self runtime
				evaluate: ('import {1}; {1}.{2}(*{3})' format: {(self containingArtefact file basename splitBy: '.') first. name. arguments})
				in: self containingArtefact file parent]]
]

{ #category : #'as yet unclassified' }
SBExample2 >> buildJavaScript [
	<lang: #javascript match: '(object (pair key: (string (string_fragment) ="args") (arrow_function (_) @arguments)) (pair key: (string (string_fragment) ="_sb_example") (string (string_fragment) @name)))' sample: '{"_sb_example": "example", "args": () => []}' keyword: 'example'>

	self
		layoutInset: 8;
		layoutPolicy: SBAlgebraLayout new;
		listDirection: #leftToRight;
		cellPositioning: #center;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		minimumWidth: 200 sbScaled;
		cellGap: 4 sbScaled.
	
	self
		removeAllMorphs;
		addMorphBack: (SBIcon iconPause
			small;
			color: (Color r: 1 g: 1 b: 1);
			on: #click send: #toggleRunning to: self);
		addMorphBack: (self createBinding: [SBTextBubble new layoutInset: 4 sbScaled] contents: 'name');
		addMorphBack: (SBStringMorph new contents: 'args:');
		addMorphBack: ((self createBindingBlock: 'arguments')
			color: (Color r: 1 g: 1 b: 1);
			layoutInset: 4 sbScaled;
			hResizing: #shrinkWrap;
			wrapCentering: #leftToRight)
]

{ #category : #'as yet unclassified' }
SBExample2 >> buildPython [
	<lang: #python match: '(dictionary (pair key: (string) ="args" (lambda (_) @arguments)) (pair key: (string) ="_sb_example" (string) @name))' sample: '{"_sb_example": "example", "args": lambda: []}' keyword: 'example'>

	self
		layoutInset: 8;
		layoutPolicy: SBAlgebraLayout new;
		listDirection: #leftToRight;
		cellPositioning: #center;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		minimumWidth: 200 sbScaled;
		cellGap: 4 sbScaled.
	
	self
		removeAllMorphs;
		addMorphBack: (SBIcon iconPause
			small;
			color: (Color r: 1 g: 1 b: 1);
			on: #click send: #toggleRunning to: self);
		addMorphBack: (self createBinding: [SBTextBubble new layoutInset: 4 sbScaled] contents: 'name');
		addMorphBack: (SBStringMorph new contents: 'args:');
		addMorphBack: ((self createBindingBlock: 'arguments')
			color: (Color r: 1 g: 1 b: 1);
			layoutInset: 4 sbScaled;
			hResizing: #shrinkWrap;
			wrapCentering: #leftToRight)
]

{ #category : #'as yet unclassified' }
SBExample2 >> drawnColor [

	^ Color veryDarkGray
]

{ #category : #'as yet unclassified' }
SBExample2 >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: #layoutCommands separatedBy: [SBAlgebraCommand gap])
]
