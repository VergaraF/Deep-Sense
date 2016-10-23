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
            if (song).shape[0] > 50:
                songs.append(song)
##            else:
##                print(f)
        except Exception as e:
            raise e
            
    return songs

songs=get_songs('Pop_Music_Midi')
print(len(songs),' songs are processed')

note_range=102-24
timesteps=10
n_visible=2*note_range*timesteps
n_hidden=50
num_epochs=200
batch_size=60
lr=tf.constant(0.005,tf.float32)

x=tf.placeholder(dtype=tf.float32,[None,n_visible],name='x')
W=tf.Variable(tf.random_normal([n_visible,n_hidden]),name="W")
