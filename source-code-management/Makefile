openchs_product_repos = openchs-client openchs-server infra rules-config openchs-reporting auth openchs-admin-client
openchs_implementation_repos = lbp-arogyadoot ashwini calcutta-kids tt-ncd-screening sewa-rural jss unicef-moha kalap

try:
	@for repo in $(openchs_repos) ; do \
        echo $$repo ; \
	done

define _git_multiple
	@for repo in $2 ; do \
		echo $$repo ; \
		git --git-dir=../../$$repo/.git --work-tree=../../$$repo $1 ; \
	done
endef

openchs_git_status_product:
	$(call _git_multiple,status -s,$(openchs_product_repos))

openchs_overwrite_from_repo_product:
	$(call _git_multiple,checkout .,$(openchs_product_repos))

openchs_switch_to_master_product:
	$(call _git_multiple,checkout master,$(openchs_product_repos))

openchs_pull_product:
	$(call _git_multiple,pull,$(openchs_product_repos))

openchs_branch_product:#branch=
	$(call _git_multiple,checkout -b $(branch),$(openchs_product_repos))
	$(call _git_multiple,push -u origin $(branch),$(openchs_product_repos))
	cd ../../rules-config && git checkout build && git pull && git checkout -b build-$(branch) && git push -u origin build-$(branch)

openchs_commit_stat:
	@for repo in $(openchs_repos) ; do \
		echo $$repo ; \
		git --git-dir=../../$$repo/.git --work-tree=../../$$repo shortlog -s master@{$(from)}...master@{$(to)} ; \
	done