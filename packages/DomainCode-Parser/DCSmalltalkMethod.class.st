Class {
	#name : #DCSmalltalkMethod,
	#superclass : #SBBlock,
	#instVars : [
		'methodClass'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCSmalltalkMethod class >> emptyIn: aClass [

	^ self new emptyIn: aClass
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod class >> for: aCompiledMethod [

	^ aCompiledMethod isSandblock ifFalse: [self new for: aCompiledMethod] ifTrue: [self new emptyIn: aCompiledMethod methodClass]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod class >> newWith: aString in: aClass [

	^ self new in: aClass with: aString
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> blockForPC: aNumber isActiveFrame: aBoolean in: aCompiledCode [

	| pc |
	pc := aBoolean ifTrue: [aNumber] ifFalse: [aCompiledCode pcPreviousTo: aNumber].
	(self method sourceString parseAsMethodFor: self methodClass) rawSourceRanges keysAndValuesDo: [:node :range | (node pc = pc or: [node pc = (aCompiledCode -> pc)]) ifTrue: [^ self method smallestBlockEncompassig: (SBTSRange start: range start - 1 size: range size)]].
	^ nil
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> browse [
	<action>

	Browser newOnClass: self methodClass selector: self selector
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> category [

	^ self methodClass organization categoryOfElement: self selector
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> compiledMethod [

	^ self methodClass >> self selector
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> emptyIn: aClass [

	methodClass := aClass.
	self addMorphBack: (DCBlock parseBlock: '__sb' language: SBTSSmalltalk)
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> externalModification: aBoolean [

	self setProperty: #externalModificationFlag toValue: aBoolean
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> for: aCompiledMethod [

	methodClass := aCompiledMethod methodClass.
	self addMorphBack: (DCBlock parseBlock: aCompiledMethod getSource asString language: SBTSSmalltalk)
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> hasExternalModification [

^ self valueOfProperty: #externalModificationFlag ifAbsent: [ false ]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> ignoreChangeNotifierDuring: aBlock [

	self setProperty: #ignoreChangeNotifier toValue: true.
	
	aBlock ensure: [self removeProperty: #ignoreChangeNotifier]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> in: aClass with: aString [

	methodClass := aClass.
	self addMorphBack: (DCBlock parseBlock: aString language: SBTSSmalltalk)
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> initialize [

	super initialize.
	
	self
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutPolicy: TableLayout new;
		attachDecorator: SBMoveDecorator new;
		attachDecorator: SBResizableDecorator new;
		layoutInset: 0
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> intoWorld: aWorld [

	super intoWorld: aWorld.
	SystemChangeNotifier uniqueInstance
		noMoreNotificationsFor: self;
		notify: self ofSystemChangesOfItem: #method using: #methodChanged:
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> isMethod [

	^ true
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs collect: [:b | b layoutCommands] separatedBy: [SBAlgebraCommand hardLine]);
		morph: self
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> messageSendForError: anError argsDo: aBlock [

	| context message |
	context := anError signalerContext findContextSuchThat: [:c | " don't look for a block but for the home method of a block "
	c method method = self compiledMethod].
	message := self
		blockForPC: context pc
		isActiveFrame: context = anError signalerContext
		in: context method.
	aBlock
		value: message
		value: ((anError signalerContext findContextSuchThat: [:c | c sender = context]) arguments collectWithIndex: [:arg :index | (message childNodes at: 2 + (index - 1 * 2) + 1) -> arg])
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> method [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> methodChanged: anEvent [

	((self hasProperty: #ignoreChangeNotifier) not and: (anEvent item selector = self selector and: [anEvent item methodClass = self methodClass])) ifTrue: [
		anEvent isRemoved ifTrue: [^ self delete].
		anEvent isModified ifTrue: [
			^ self hasUnsavedChanges
				ifTrue: [self externalModification: true]
				ifFalse: [self reloadMethodInPlaceUndoable: false]]]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> methodClass [

	^ methodClass
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> object [

	^ (self methodClass ifNil: [^ self])
		compiledMethodAt: self selector
		ifAbsent: [self]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> relatedClass [

	^ self methodClass
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> reloadMethodInPlaceUndoable: aBoolean [

	| reloaded |
	self externalModification: false.
	reloaded := (DCSmalltalkMethod for: self containingArtefact object)
		hResizing: self containingArtefact hResizing;
		width: self containingArtefact width;
		yourself.
	
	self isInWorld ifTrue: [
		aBoolean
			ifTrue: [self sandblockEditor do: (SBReplaceCommand new target: self replacer: reloaded)]
			ifFalse: [self replaceBy: reloaded]].
	^ reloaded
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	| text newSelector |
	(self hasExternalModification not or: [UIManager default confirm: 'Method may have changed elsewhere, continue?'])
		ifTrue: [self externalModification: false]
		ifFalse: [^ false].
	
	self firstSubmorph queryState errorsDo: [:error |
		aFixBoolean ifTrue: [error tryFixIfFail: [^ false]] ifFalse: [^ false].
		"errors are applied and removed on the next tick only"
		self world ifNotNil: #doOneCycleNow].
	
	aQuickBoolean ifFalse: [self method prettyPrint].
	text := self method sourceString.
	
	self ignoreChangeNotifierDuring: [
		newSelector := self methodClass
			compile: text withSqueakLineEndings asText
			classified: self category].
	
	^ true
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> selector [

	| selector |
	selector := (self method queryFirst: {[:x | x is: #(#'unary_selector' #'binary_selector' #'keyword_selector')]}) ifNil: [^ ''].
	
	^ (((selector childSandblocks viewFrom: 1 by: 2) collect: [:p | p contents]) joinSeparatedBy: '') asSymbol
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> type [

	^ nil
]
