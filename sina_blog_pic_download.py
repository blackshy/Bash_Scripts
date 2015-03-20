#!/usr/bin/env python
import urllib2,urllib,re,os
from bs4 import BeautifulSoup

def GetArticleInfo(self,article_regular):
	article_page = urllib2.urlopen(self)
	article_soup = BeautifulSoup(article_page)
	article_url_list = article_soup.find_all(href = re.compile(article_regular))
	for i in range(0,len(article_url_list)):
		del article_url_list[i]['target']
	total_article_url_list.append(article_url_list)
	return article_url_list
	
def GetPictureInfo(self,picture_regular):
	picture_url_list = []
	picture_page = urllib2.urlopen(self)
	picture_soup = BeautifulSoup(picture_page)
	img_tag = picture_soup.find_all(href = re.compile(picture_regular))
	for i in range(0,len(img_tag)):
		del img_tag[0]['src']
                del img_tag[0]['name']
                del img_tag[0]['width']
                del img_tag[0]['alt']
                del img_tag[0]['height']
		picture_url_list.append(img_tag[i])
	total_picture_url_list.append(picture_url_list)
	return picture_url_list
	
if __name__ == '__main__':
	top_url = "/Users/Michael/Desktop/test_blog"
	article_url_common_start =  "http://blog.sina.com.cn/s/articlelist_1618180340_0_"
	article_url_common_end =  ".html"
	start_url_num = 1
	end_url_num = 2
	article_regular = "blog.sina.com.cn\/s\/blog"
	picture_regular = "album.sina.com.cn"
	total_article_url_list = []
	total_picture_url_list = []
	for i in range(start_url_num,end_url_num):
		article_url = article_url_common_start + str(i) + article_url_common_end
		article_url_list = GetArticleInfo(article_url,article_regular)
		for j in range(0,len(article_url_list)):
			picture_url = article_url_list[j]['href']
			picture_directory = article_url_list[j]['title']
			os.mkdir(picture_directory)
			picture_url_list = GetPictureInfo(picture_url,picture_regular)
			for k in range(0,len(picture_url_list)):
				picture_real_src = picture_url_list[k].find_all('img')[0]['real_src']
		#		orignal_replace = re.compile("mw690")
				picture_orignal_real_src = picture_real_src.replace('mw690','orignal')
				dist = os.path.join(os.path.abspath(picture_directory),str(k) + ".jpg")
				print "Downloading     " + dist
				urllib.urlretrieve(picture_orignal_real_src,dist)
