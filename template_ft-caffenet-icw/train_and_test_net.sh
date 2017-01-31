# set the directory where you have downloaded iCW and cloned the tutorial
LAB_DIR=/home/icub/giulia/Dropbox/SANDBOX/VVV17/vvv17-tutorials
echo $LAB_DIR

########## iCW directory
# including the iCW dir and with a '/' at the end (see the example)
IMAGES_DIR=$LAB_DIR/iCW/
echo $IMAGES_DIR

########## TUTORIAL directory and EXERCISE
TUTORIAL_DIR=$LAB_DIR/assignment_dl-tuning
echo $TUTORIAL_DIR
# set the name of the example/exercise
EX=template_ft-caffenet-icw
echo $EX
# set the name of the protocol
PROTOCOL=protocol-name
echo $PROTOCOL

########## CAFFE stuff
# path to caffe executable
CAFFE_BIN=$Caffe_ROOT/build/tools/caffe
echo $CAFFE_BIN
# path to CaffeNet model (you should already have it if you followed instructions before arriving)
WEIGHTS_FILE=$Caffe_ROOT/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel
echo $WEIGHTS_FILE

########## SCRIPTS
# set the path to the scripts (that you have just built)
COMPUTE_MEAN_BIN=$TUTORIAL_DIR/scripts/src/build/compute_mean_vvv17/compute_mean_vvv17
echo $COMPUTE_MEAN_BIN
CREATE_LMDB_BIN=$TUTORIAL_DIR/scripts/src/build/create_lmdb_vvv17/create_lmdb_vvv17
echo $CREATE_LMDB_BIN
PARSE_LOG_SH=$TUTORIAL_DIR/scripts/parse_caffe_log.sh
echo $PARSE_LOG_SH
CLASSIFY_IMAGE_LIST_BIN=$TUTORIAL_DIR/scripts/src/build/classify_image_list_vvv17/classify_image_list_vvv17
echo $CLASSIFY_IMAGE_LIST_BIN

########## SOLVER --> ARCHITECTURE and TEST
# path to the solver, which points to the train_val.prototxt
SOLVER_FILE=$TUTORIAL_DIR/$EX/$PROTOCOL/solver.prototxt
echo $SOLVER_FILE
# path to deploy.prototxt
DEPLOY_FILE=$TUTORIAL_DIR/$EX/$PROTOCOL/deploy.prototxt
echo $DEPLOY_FILE

########## TRAIN, VALIDATION and TEST sets: list of images
FILELIST_TRAIN=$TUTORIAL_DIR/$EX/images_lists/train.txt
echo $FILELIST_TRAIN
FILELIST_VAL=$TUTORIAL_DIR/$EX/images_lists/val.txt
echo $FILELIST_VAL
FILELIST_TEST_DAY1=$TUTORIAL_DIR/$EX/images_lists/test_day1.txt
echo $FILELIST_TEST_DAY1
FILELIST_TEST_DAY2=$TUTORIAL_DIR/$EX/images_lists/test_day2.txt
echo $FILELIST_TEST_DAY2
LABELS_FILE=$TUTORIAL_DIR/$EX/images_lists/labels.txt
echo $LABELS_FILE

########## TRAIN (plus mean image), VALIDATION and TEST databases for caffe
LMDB_TRAIN=$TUTORIAL_DIR/$EX/lmdb_train/
echo $LMDB_TRAIN
BINARYPROTO_MEAN=$TUTORIAL_DIR/$EX/mean.binaryproto
echo $BINARYPROTO_MEAN
LMDB_VAL=$TUTORIAL_DIR/$EX/lmdb_val/
echo $LMDB_VAL

########## create DATABASES
rm -rf $LMDB_TRAIN
$CREATE_LMDB_BIN --resize_width=256 --resize_height=256 --shuffle $IMAGES_DIR $FILELIST_TRAIN $LMDB_TRAIN
$COMPUTE_MEAN_BIN $LMDB_TRAIN $BINARYPROTO_MEAN
rm -rf $LMDB_VAL
$CREATE_LMDB_BIN --resize_width=256 --resize_height=256 --shuffle $IMAGES_DIR $FILELIST_VAL $LMDB_VAL

########## TRAIN!

cd $TUTORIAL_DIR/$EX/$PROTOCOL

$CAFFE_BIN train -solver $SOLVER_FILE -weights $WEIGHTS_FILE --log_dir=$TUTORIAL_DIR/$EX/$PROTOCOL

$PARSE_LOG_SH $TUTORIAL_DIR/$EX/$PROTOCOL/caffe.INFO $TUTORIAL_DIR/$EX/$PROTOCOL/caffe_INFO_train.txt $TUTORIAL_DIR/$EX/$PROTOCOL/caffe_INFO_val.txt

FINAL_SNAP=$TUTORIAL_DIR/$EX/$PROTOCOL/icw_iter_144.caffemodel
FINAL_MODEL=$TUTORIAL_DIR/$EX/$PROTOCOL/final.caffemodel
mv $FINAL_SNAP $FINAL_MODEL
rm $TUTORIAL_DIR/$EX/$PROTOCOL/icw_iter_144.solverstate

########## TEST using deploy.prototxt
# day1
$CLASSIFY_IMAGE_LIST_BIN $DEPLOY_FILE $FINAL_MODEL $BINARYPROTO_MEAN $LABELS_FILE $IMAGES_DIR $FILELIST_TEST_DAY1
# day2
$CLASSIFY_IMAGE_LIST_BIN $DEPLOY_FILE $FINAL_MODEL $BINARYPROTO_MEAN $LABELS_FILE $IMAGES_DIR $FILELIST_TEST_DAY2




