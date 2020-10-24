# ETD Structure Classifier

**NOTE:** This is a Proof of Concept and not currently intended for production use.

This is a trainer / classifier intended to classify a page from a plain text document to determine if is a page that contains a certain structure (e.g. a Table of Contents page, a Text page, or a Bibliography/Citations page).

This is currently using a Naive Bayes (via the `nbayes` gem) to classify the pages, and is trained on a set of world accessible Electronic Thesis and Dissertations from the Stanford Digital Repository.  This is currently doing very basic text tokenization for the training and classification, but seemingly has decent results compared with other tokenization strategies we've  tried thus far.

## Initialize the Classifier

This is assuming that you're in the root of this repository and running in a ruby environment (e.g. `irb`)

```ruby
require './etd_structure_classifier'

classifier = EtdStructureClassifier.new
```

## Training the model

This repository comes with a persisted model trained from the data already and will be ready to do classification out-of-the-box.  However; you can re-train this model or train it on different and/or additional data.

The training data used for this model is included in `.tar.gz` files in the `training_data` directory.  You can uncompress those (or create the resulting directories and add data yourself).

```ruby
classifier.train
```

This will randomize all the files in the training directory, and train the model on all but 20 of each category.  The other 20 will be reserved for running the classifier on and reporting the results.

```ruby
classifier.test
```

## Classifying Text

You can now use the classifier to classify text to determine what is the dominant structure in the content.

_Examples taken from https://purl.stanford.edu/nv895qp6116_
```ruby
classifier.classify(
  '(71) Gabrielli, C.; Grand, P. P.; Lasia, A.; Perrot, H. Investigation of
        Hydrogen Adsorption and Absorption in Palladium Thin Films: II. Cyclic
        Voltammetry. Journal of The Electrochemical Society 2004, 151, A1937-A1942.'
)
=> "BIB"

classifier.classify(
  'Currently, several different types of materials have been identified as
   promising candidates for alkaline O2 reduction. The majority of them are metal NPs
   based on Pt, Pd, Au, and Ag. Different strategies44 have been developed to improve
   the specific activity as well as mass activity of these materials, including
   morphology/surface atomic structure control, electronic structure control via alloying,
   composite materials, etc. Nanostructured metal oxide materials are another large group
   of catalysts being extensively studied, such as cobalt or manganese-based spinel,54
   perovskite,
   53 etc. These metal oxides are typically dispersed on conductive carbon
   support to improve the electrical conductivity.54 Apart from these, good alkaline O2
   reduction activity has also been achieved on nitrogen-doped carbon materials.55'
)

=> "TEXT"

classifier.classify(
  'Acknowledgement.................................................viii
   Table of Contents .....................................................x
   List of Illustrations ................................................xiii
   List of Tables..........................................................xx'
)
=> "TOC"
```

## Persisting/Destroying the Model

You can persist the model that you've trained as well as remove the current model.  Note that the classifier in memory will still work after clearing the model, so a new instance of the classifier would need to be instatiated

```ruby

classifier.persist!
classifier.persisted?
=> true

classifier.clear!
classifier.persisted?
=> false
```
