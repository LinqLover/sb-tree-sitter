Class {
	#name : #DCFileEditor,
	#superclass : #SBBlock,
	#instVars : [
		'file'
	],
	#category : #'DomainCode-Core'
}

{ #category : #'as yet unclassified' }
DCFileEditor >> file [

	^ self firstSubmorph firstSubmorph firstSubmorph
]

{ #category : #'as yet unclassified' }
DCFileEditor >> file: aFile [

	file := aFile.
	
	self
		changeTableLayout;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		addMorphBack: (ScrollPane new
			hResizing: #spaceFill;
			vResizing: #spaceFill;
			hScrollBarPolicy: #never;
			in: [:scroll |
				scroll scroller
					hResizing: #spaceFill;
					addMorphBack: ((SBTSFile languageForPathAskInstall: aFile basename)
						ifNotNil: [:language |
							(DCBlock parseBlock: file contents language: language)
								hResizing: #spaceFill;
								vResizing: #shrinkWrap]
						ifNil: [self shouldBeImplemented])];
			yourself)
]

{ #category : #'as yet unclassified' }
DCFileEditor >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
DCFileEditor >> reloadArtefact [
	<action>

	self replaceBy: (DCFileEditor new file: file)
]

{ #category : #'as yet unclassified' }
DCFileEditor >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	FileStream
		forceNewFileNamed: file asString
		do: [:stream | stream nextPutAll: self file sourceString withUnixLineEndings].
	^ true
]
