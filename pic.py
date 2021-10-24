import  wave
import matplotlib.pyplot as plt
import os
import sys
import numpy as np
import IPython.display as ipd
from scipy.io.wavfile import read
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow.keras import backend as K
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
import pydub
from pydub import AudioSegment
from flask_cors import CORS
from flask import Flask,request
from flask_restful import Resource, Api


#AudioSegment.converter = "/Library/anaconda3/bin/ffmpeg.exec"


folder = './wav'
for filename in os.listdir(folder):
       infilename = os.path.join(folder,filename)
       if not os.path.isfile(infilename): continue
       oldbase = os.path.splitext(filename)
       newname = infilename.replace('.tmp', '.m4a')
       output = os.rename(infilename, newname)


      
# Convert m4a extension files to wav extension files



formats_to_convert = ['.m4a']

for (dirpath, dirnames, filenames) in os.walk('./wav'):
    for filename in filenames:
        if filename.endswith(tuple(formats_to_convert)):

            filepath = dirpath + '/' + filename
            (path, file_extension) = os.path.splitext(filepath)
            file_extension_final = file_extension.replace('.', '')
            try:
                track = AudioSegment.from_file(filepath,
                        file_extension_final)
                wav_filename = filename.replace(file_extension_final, 'wav')
                wav_path = dirpath + '/' + wav_filename
                print('CONVERTING: ' + str(filepath))
                file_handle = track.export(wav_path, format='wav')
                os.remove(filepath)
                filepath=''
            except:
                print("ERROR CONVERTING " + str(filepath))
        else:
            filename=""
    filenames=[]

    
app = Flask(__name__)
CORS(app)
@app.route('/', methods = ['GET','POST'])
def value():
    if request.method =='POST':
        post=request.form.get('re')
        print(post)       
sequences = []
             #1103','1104','1105','1106','1107',
 #            '1191','1192','1193','1194','1195','1196','1197','1198','1199','11910',
  #           '11911','11912','11913','11914','11916','11917','11918','11919','11920',
   #          '11921','11922','11923','11924','11926','11927','11928','11929','11930',
    #         '11931','11932','11933','11934','11935','11936','11937','11938','11939','11940',
     #        '11941','11942','11943','11944','11945' ,'11946' ,'11947','11948','11949','11950',
      #       '11951','11952','11953','11954','11955','11956','11957','11958',
       #      'fire1','fire2','fire3','fire4','fire5','fire6','fire7','fire8','fire9','fire10','fire11','fire12']

###########打開音檔轉頻譜圖###########
for i in sequences:
    # 調用wave模塊中的open函數，打開語音文件。
    f = wave.open('wav/'+ i+ '.wav','rb')
    # 得到語音參數
    params = f.getparams()
    nchannels, sampwidth, framerate,nframes = params[:4]
    # 得到的數據是字符串，需要將其轉成int型
    strData = f.readframes(nframes)
    wavaData = np.frombuffer(strData,dtype=np.int16)
    # 歸一化
    wavaData = wavaData * 1.0/max(abs(wavaData))
    # .T 表示轉置
    wavaData = np.reshape(wavaData,[nframes,nchannels]).T
    f.close()
    # 繪制頻譜
    plt.specgram(wavaData[0],Fs = framerate,scale_by_freq=True,sides='default')
    plt.ylabel('Frequency')
    plt.xlabel('Time(s) '+ i)
    plt.savefig('jpg/' + i + '.jpg')
    plt.show()
    
###########載入模型辨識聲音類型###########
    # 載入訓練好的模型
    net = load_model('model-resnet50-final.h5')
    
    cls_list = ['110', '119','fire']

    img = image.load_img('jpg/' + i + '.jpg', target_size=(224, 224))
    if img is None:
        continue
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis = 0)
    pred = net.predict(x)[0]
    top_inds = pred.argsort()[::-1][:5]
    print(f)
    #存放目前聲音類型
    data_type = ''
    #存放最終要回傳給app端的類別
    final_type = ''
    #存放相似度陣列
    typedata_list = []
    a = ''
    #存放類型的順序
    type_list = []
 
    for i in top_inds:
        print('    {:.3f}  {}'.format(pred[i], cls_list[i]))
    #將pred[i]陣列存入type_list中，讓相符度可透過陣列找出最大值
        a = str('{:.3f}'.format(pred[i]))
        typedata_list.append(a)
        type_list.append(cls_list[i])
        
    #利用串列比較，找出最大值
    for k in range(0,3):
        if(float(typedata_list[k]) > 0.1):
            if(float(typedata_list[k]) > float(typedata_list[k-1])):
                data_type = type_list[k]
                print('檢查點：' + '(確認類型與數值比較)：' + data_type + '  ' + typedata_list[k] + '>' + typedata_list[k-1])
                
    if(data_type == '119'):
        print('檢查點：(if判斷類型)' + 'A')
        final_type = final_type + 'A'
    elif(data_type == '110'):
        print('檢查點：(if判斷類型)' + 'B')
        final_type = final_type + 'B'
    elif(data_type == 'fire'):
        print('檢查點(if判斷類型)：' + 'C')
        final_type = final_type + 'C'
    #若聲音的相似度不超過八成，即判定不是警笛聲(暫時輸出無法辨識)
    elif(data_type == ''):
        print('檢查點(if判斷類型)：' + '無法辨識')
    #用來判斷data_type有無存放過多的值
    else:
        print('檢查點(if判斷類型)：' + '其他錯誤')
    #確認各項值輸出是否正確
    print('\n檢查點：data_type：' + data_type + '\n檢查點：final_type：' + final_type + '\n')
    
###########音檔轉音波圖用來判斷距離###########
for i in sequences:
    wav = 'wav/'+ i + '.wav'
    sr, samps = read(wav)
    ipd.Audio(samps, rate=sr)
        # creating variables for clarification
    samples_per_second = sr
    total_samples = len(samps)
    time_seconds = total_samples / samples_per_second
    #print("Sampling rate: ", samples_per_second)
    #print("Total number of samples: ", total_samples)
    #print("Total time in seconds: ", time_seconds)
    time_vector = np.linspace(0, time_seconds, total_samples)
        
    plt.plot(time_vector[0:100000000], samps[0:100000000])
    plt.title(wav)
    plt.xlabel('time (sec)')
    plt.ylabel('amplitude')
    plt.savefig('distant/jpg/' + i + '.jpg')
    plt.show()
                
            
###########載入模型判斷距離###########
    # 載入訓練好的模型
    net = load_model('model-resnet50-distant.h5')
    
    cls_list = ['near-distant', 'distant-near']
    
    img = image.load_img('distant/jpg/' + i + '.jpg', target_size=(224, 224))
    if img is None:
        continue
    x = image.img_to_array(img)
    x = np.expand_dims(x, axis = 0)
    pred = net.predict(x)[0]
    top_inds = pred.argsort()[::-1][:5]
    print(f)
    #存放目前距離類型
    dis_type = ''
    #存放目前距離判出值
    disdata_type = 0
    
    for i in top_inds:
        print('    {:.3f}  {}'.format(pred[i], cls_list[i]))
        if(pred[i] > disdata_type):
            #print(pred[i])
            dis_type = cls_list[i]
            disdata_type = pred[i]
            #print('目前判斷距離：' + dis_type)
            #print(disdata_type)
            if(pred[i] > disdata_type):
                dis_type = cls_list[i]
         
    print('最終判斷距離：' + dis_type)
    if(dis_type == 'near-distant'):
        print('遠離')
        final_type = final_type + '1'
    elif(dis_type == 'distant-near'):
        print('靠近')
        final_type = final_type + '2'
    else:
        print('無法辨識')
        
    print('\n===========對應表===========\nA：119   1：遠離\nB：110   2：靠近\nC：fire')
    print('===========原本音檔：' + sequences[0] + '===========')
    print('===========final_type：' + final_type + '===========')

def get(self, data: str):
    print(final_type)
    return final_type

if __name__ == '__main__':
    app.run(host='163.17.135.232',debug=True)
    
    

