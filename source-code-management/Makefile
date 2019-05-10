openchs_product_repos = openchs-client openchs-server infra rules-config openchs-reporting openchs-webapp
openchs_implementation_repos = openchs-impls/jss-sickle-cell-screening openchs-impls/ashwini openchs-impls/calcutta-kids openchs-impls/tt-ncd-screening openchs-impls/sewa-rural openchs-impls/jss openchs-impls/unicef-moha openchs-impls/kalap

branch=
command=
product:=$(filter yes,$(product))
repos=$(if $(product),$(openchs_product_repos),$(openchs_implementation_repos))

try:
	@for repo in $(repos) ; do \
        echo $$repo ; \
	done

openchs_git_clone:
	@for repo in $(openchs_product_repos) $(openchs_implementation_repos) ; do \
		echo $$repo ; \
		git clone git@github.com:OpenCHS/$$repo.git; \
	done

define _git_multiple
	@for repo in $2 ; do \
		echo $$repo ; \
		git --git-dir=../../$$repo/.git --work-tree=../../$$repo $1 ; \
	done
endef

git_multiple:
	$(call _git_multiple,$(command),$(repos))

openchs_git_status:
	$(call _git_multiple,status -s,$(repos))

openchs_overwrite_from_repo:
	$(call _git_multiple,checkout .,$(repos))

openchs_switch_to_master:
	$(call _git_multiple,checkout master,$(repos))

openchs_pull:
	$(call _git_multiple,pull,$(repos))

define _branch_rule_config
	cd ../../rules-config && git checkout build && git pull && git checkout -b build-$(branch) && git push -u origin build-$(branch)
endef

openchs_branch:
	$(call _git_multiple,checkout -b $(branch),$(repos))
	$(call _git_multiple,push -u origin $(branch),$(repos))
	$(if $(product),$(call _branch_rule_config))

openchs_commit_stat:
	@for repo in $(repos) ; do \
		echo $$repo ; \
		git --git-dir=../../$$repo/.git --work-tree=../../$$repo shortlog -s master@{$(from)}...master@{$(to)} ; \
	done