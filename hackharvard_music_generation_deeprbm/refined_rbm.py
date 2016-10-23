
import numpy as np
import pandas as pd
import msgpack
import glob
import tensorflow as tf
from tensorflow.python.ops import control_flow_ops
from tqdm import tqdm


import midi_manipulation

def get_songs(path):
    files = glob.glob('{}/*.mid*'.format(path))
    songs = []
    for f in tqdm(files):
        try:
            song = np.array(midi_manipulation.midiToNoteStateMatrix(f))
            if np.array(song).shape[0] > 50:
                songs.append(song)
        except Exception as e:
            raise e           
    return songs



####################songs are got here###########

songs = get_songs('fear_midi') #These songs have already been converted from midi to msgpack
print "{} songs processed".format(len(songs))

lowest_note = midi_manipulation.lowerBound #the index of the lowest note on the piano roll
highest_note = midi_manipulation.upperBound #the index of the highest note on the piano roll
note_range=highest_note-lowest_note#the note range

num_timesteps  = 20 #This is the number of timesteps that we will create at a time
n_visible      = 2*note_range*num_timesteps #This is the size of the visible layer. 
n_hidden_1       = 100 #This is the size of the hidden layer
n_hidden_2      =25

num_epochs = 200 #The number of training epochs that we are going to run. For each epoch we go through the entire data set.
batch_size = 100 #The number of training examples that we are going to send through the RBM at a time. 
lr         = tf.constant(0.005, tf.float32) #The learning rate of our model
### Variables:
# Next, let's look at the variables we're going to use:

x  = tf.placeholder(tf.float32, [None, n_visible], name="x") #The placeholder variable that holds our data
W_1  = tf.Variable(tf.random_normal([n_visible, n_hidden_1], 0.01), name="W_1") #The weight matrix that stores the edge weights
W_2  = tf.Variable(tf.random_normal([n_hidden_1, n_hidden_2], 0.01), name="W_1") #The weight matrix that stores the edge weights

bh_1 = tf.Variable(tf.zeros([1, n_hidden_1],  tf.float32, name="bh_1")) #The bias vector for the hidden layer
bh_2 = tf.Variable(tf.zeros([1, n_hidden_2],  tf.float32, name="bh_2")) #The bias vector for the hidden layer

bv = tf.Variable(tf.zeros([1, n_visible],  tf.float32, name="bv")) #The bias vector for the visible layer


#This function lets us easily sample from a vector of probabilities
def sample(probs):
    #Takes in a vector of probabilities, and returns a random vector of 0s and 1s sampled from the input vector
    return tf.floor(probs + tf.random_uniform(tf.shape(probs), 0, 1))

#This function runs the gibbs chain. We will call this function in two places:
#    - When we define the training update step
#    - When we sample our music segments from the trained RBM
def gibbs_sample(k):
    #Runs a k-step gibbs chain to sample from the probability distribution of the RBM defined by W, bh, bv
    def gibbs_step(count, k, xk):
        #Runs a single gibbs step. The visible values are initialized to xk
        h_1k = sample(tf.sigmoid(tf.matmul(xk, W_1) + bh_1))#Propagate the visible values to sample the hidden values
        print'done'
        h_2k = sample(tf.sigmoid(tf.matmul(h_1k, W_2) + bh_2))
        print'yo'
        h_1k = sample(tf.sigmoid(tf.matmul(h_2k,tf.transpose(W_2)) + bh_1))
        xk = sample(tf.sigmoid(tf.matmul(h_1k, tf.transpose(W_1)) + bv)) #Propagate the hidden values to sample the visible values
        return count+1, k, xk

    #Run gibbs steps for k iterations
    ct = tf.constant(0) #counter
    count=0
    xk=x
    num_iter=5
    while(count<num_iter):
        [count,num_iter,x_sample]=gibbs_step(count,k,xk)
##    [_,_,x_sample]=gibbs_step(0,1,x)
##    [_, _, x_sample] = tf.while_loop(lambda count, num_iter, *args: count < num_iter,
##                                         gibbs_step, [ct, tf.constant(k), x], 1, False)
    #This is not strictly necessary in this implementation, but if you want to adapt this code to use one of TensorFlow's
    #optimizers, you need this in order to stop tensorflow from propagating gradients back through the gibbs step
    x_sample = tf.stop_gradient(x_sample) 
    return x_sample


### Training Update Code
# Now we implement the contrastive divergence algorithm. First, we get the samples of x and h from the probability distribution
#The sample of x
x_sample = gibbs_sample(1) 
#The sample of the hidden nodes, starting from the visible state of x
x_temp = (tf.sigmoid(tf.matmul(x, W_1) + bh_1))
h=sample(tf.sigmoid(tf.matmul(x_temp,W_2)+bh_2))
#The sample of the hidden nodes, starting from the visible state of x_sample
xt_temp = (tf.sigmoid(tf.matmul(x_sample, W_1) + bh_1))
h_sample = sample(tf.sigmoid(tf.matmul(xt_temp, W_2) + bh_2))

##cost=tf.reduce_mean(tf.reduce_sum(tf.square(tf.sub(h,h_sample))),reduction_indices=[1])
##train_step=tf.train.GradientDescentOptimizer(0.5).minimize(cost)

###Next, we update the values of W, bh, and bv, based on the difference between the samples that we drew and the original values
size_bt = tf.cast(tf.shape(x)[0], tf.float32)
W_1_adder  = tf.mul(lr/size_bt, tf.sub(tf.matmul(tf.transpose(x), x_temp), tf.matmul(tf.transpose(x_sample), xt_temp)))
W_2_adder  = tf.mul(lr/size_bt, tf.sub(tf.matmul(tf.transpose(x_temp), h), tf.matmul(tf.transpose(xt_temp), h_sample)))

bv_adder = tf.mul(lr/size_bt, tf.reduce_sum(tf.sub(x, x_sample), 0, True))
bh_1_adder = tf.mul(lr/size_bt, tf.reduce_sum(tf.sub(x_temp,xt_temp), 0, True))
bh_2_adder = tf.mul(lr/size_bt, tf.reduce_sum(tf.sub(h, h_sample), 0, True))
##cost=tf.reduce_sum(tf.sub(h,h_sample),reduction_indices=None)
##grad=tf.train.GradientDescentOptimizer(0.5).minimize(cost)

###When we do sess.run(updt), TensorFlow will run all 3 update steps
updt = [W_1.assign_add(W_1_adder),W_2.assign_add(W_2_adder), bv.assign_add(bv_adder), bh_1.assign_add(bh_1_adder),bh_2.assign_add(bh_2_adder)]

saver=tf.train.Saver()
with tf.Session() as sess:
    #First, we train the model
    #initialize the variables of the model
    init = tf.initialize_all_variables()
    sess.run(init)
    #Run through all of the training data num_epochs times
    for epoch in tqdm(range(num_epochs)):
        for song in songs:
            #The songs are stored in a time x notes format. The size of each song is timesteps_in_song x 2*note_range
            #Here we reshape the songs so that each training example is a vector with num_timesteps x 2*note_range elements
            song = np.array(song)
            song = song[:np.floor(song.shape[0]/num_timesteps)*num_timesteps]
            song = np.reshape(song, [song.shape[0]/num_timesteps, song.shape[1]*num_timesteps])
            #Train the RBM on batch_size examples at a time
            for i in range(1, len(song), batch_size): 
                tr_x = song[i:i+batch_size]
                sess.run(updt, feed_dict={x: tr_x})
    save_path=saver.save(sess,"mymodels/scary.ckpt")
##                print(h)
                
##                print('\n',len(song))
    sample = gibbs_sample(1).eval(session=sess, feed_dict={x: np.zeros((25, n_visible))})
    for i in range(sample.shape[0]):
        if not any(sample[i,:]):
            continue
        #Here we reshape the vector to be time x notes, and then save the vector as a midi file
        S = np.reshape(sample[i,:], (num_timesteps, 2*note_range))
        midi_manipulation.noteStateMatrixToMidi(S, "testmusic/generated_chord_{}".format(i))
            
