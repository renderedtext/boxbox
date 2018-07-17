.PHONY: vagrant.install provision package release

REL_BUCKET=boxbox-releases

gsutil.configure:
	gcloud auth activate-service-account deploy-from-semaphore@semaphore2-prod.iam.gserviceaccount.com --key-file ~/gce-creds.json
	gcloud config set project semaphore2-prod
	gcloud container clusters get-credentials prod --zone us-east4

vagrant.install:
	wget -q -O - http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | sudo apt-key add -
	sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian bionic non-free contrib" >> /etc/apt/sources.list.d/virtualbox.org.list'
	sudo apt-get update
	sudo apt-get install virtualbox-5.1 -y
	wget https://releases.hashicorp.com/vagrant/2.1.2/vagrant_2.1.2_x86_64.deb
	sudo dpkg -i vagrant_2.1.2_x86_64.deb
	vagrant --version

provision:
	vagrant plugin install vagrant-hostmanager
	vagrant up

package:
	vagrant package --output boxbox-$(VERSION).box

release:
	gsutil cp boxbox-$(VERSION).box gs://$(REL_BUCKET)/boxbox-$(VERSION).box
	gsutil acl -R ch -u AllUsers:R gs://$(REL_BUCKET)/boxbox-$(VERSION).box
	gsutil setmeta -h "Cache-Control:private, max-age=0, no-transform" gs://$(REL_BUCKET)/boxbox-$(VERSION).box
	echo "https://storage.googleapis.com/$(REL_BUCKET)/boxbox-$(VERSION).box"
