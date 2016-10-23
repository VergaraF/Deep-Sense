import tensorflow as tf
from tensorflow.python.framework import ops
import midi_manipulation_sad
import numpy as np
lowest_note = midi_manipulation_sad.lowerBound #the index of the lowest note on the piano roll
highest_note = midi_manipulation_sad.upperBound #the index of the highest note on the piano roll
note_range=highest_note-lowest_note#the note range

#This function lets us easily sample from a vector of probabilities
def run():
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

    num_timesteps  = 20 #This is the number of timesteps that we will create at a time
    n_visible      = 2*note_range*num_timesteps #This is the size of the visible layer. 
    n_hidden       = 50 #This is the size of the hidden layer

    num_epochs = 200 #The number of training epochs that we are going to run. For each epoch we go through the entire data set.
    batch_size = 100 #The number of training examples that we are going to send through the RBM at a time. 
    lr         = tf.constant(0.005, tf.float32) #The learning rate of our model
    print('n_visible= ',n_visible)
    ### Variables:
    # Next, let's look at the variables we're going to use:

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

    saver1=tf.train.Saver()
    with tf.Session() as sess:
        saver=tf.train.Saver()

        saver1.restore(sess,"mymodels/sad.ckpt")
        print("restored")
        sample = gibbs_sample(1).eval(session=sess, feed_dict={x: np.zeros((25, n_visible))})
        print(len(sample))
        for i in range(sample.shape[0]):
            if not any(sample[i,:]):
                continue
                #Here we reshape the vector to be time x notes, and then save the vector as a midi file
            S = np.reshape(sample[i,:], (num_timesteps, 2*note_range))
            midi_manipulation_sad.noteStateMatrixToMidi(S, "l/generated_chord_{}".format(i))
            print('saved')
