Class {
	#name : #SBLatexRuntimeOSProcess,
	#superclass : #SBTSLanguageRuntime,
	#category : #'Sandblocks-Latex'
}

{ #category : #accessing }
SBLatexRuntimeOSProcess class >> language [

	^ SBLatex
]

{ #category : #accessing }
SBLatexRuntimeOSProcess class >> runtimeName [

	^ 'clang'
]

{ #category : #'runtime interface' }
SBLatexRuntimeOSProcess >> evaluate: aString [

	self halt.
]

{ #category : #'runtime interface' }
SBLatexRuntimeOSProcess >> evaluateFileAsync: aString cancel: aBlock [

	self halt.
]

{ #category : #'helper os process' }
SBLatexRuntimeOSProcess >> writeWatchSourceOn: aStream watch: aWatch [

	self halt
]
