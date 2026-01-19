// ==UserScript==
// @name         GitLab Issue → MR Helper (markdown + username, no duplicates)
// @namespace    https://gitlab.brightskiesinc.com/
// @version      2.0.0
// @description  Enhanced GitLab Issue→MR helper with branch suggestions, label pre-fill, clipboard copy, and keyboard shortcuts.
// @match        https://gitlab.brightskiesinc.com/*/*/-/issues/*
// @match        https://gitlab.brightskiesinc.com/*/*/-/merge_requests/new*
// @run-at       document-idle
// @grant        GM_addStyle
// @grant        GM_setValue
// @grant        GM_getValue
// ==/UserScript==

(function () {
    'use strict';

    const STORAGE_KEY = 'bs_gitlab_mr_template_v3';
    const MAX_AGE_MS = 4 * 60 * 60 * 1000; // 4 hours

    // ----------------- Common helpers -----------------

    function isIssuePage() {
        return /\/-\/issues\/\d+/.test(location.pathname);
    }

    function isNewMRPage() {
        return /\/-\/merge_requests\/new/.test(location.pathname);
    }

    function getIssueNumber() {
        const m = location.pathname.match(/\/-\/issues\/(\d+)/);
        return m ? m[1] : null;
    }

    function getIssueTitle() {
        const selectors = [
            'h1.title',
            'h1.issuable-title',
            '.detail-page-header-title',
            '.page-title'
        ];
        for (const sel of selectors) {
            const el = document.querySelector(sel);
            if (el && el.textContent.trim()) {
                return el.textContent.trim();
            }
        }
        return '';
    }

    // Fallback: rendered text → we only use this if JSON fails
    function getIssueBodyRenderedText() {
        const selectors = [
            '.issuable-description .md',
            '.issue-details .description .md',
            '.detail-page-description .md',
            '.description .md'
        ];
        for (const sel of selectors) {
            const el = document.querySelector(sel);
            if (el) {
                return el.innerText.trim();
            }
        }
        return '';
    }

    // 🔥 Fetch raw markdown via GitLab JSON endpoint
    async function fetchIssueMarkdown() {
        try {
            // /.../-/issues/10  →  /.../-/issues/10.json
            const cleanPath = location.pathname.replace(/[#?].*$/, '');
            const url = cleanPath + '.json';
            const resp = await fetch(url, { headers: { 'Accept': 'application/json' } });
            if (!resp.ok) return null;
            const data = await resp.json();
            // Most GitLab versions expose description as markdown here
            if (typeof data.description === 'string') {
                return data.description.trim();
            }
            // Some variants wrap it in issue/issuable
            if (data.issue && typeof data.issue.description === 'string') {
                return data.issue.description.trim();
            }
            return null;
        } catch (e) {
            console.warn('Failed to fetch issue JSON', e);
            return null;
        }
    }

    // 🔥 Try hard to get your username
    function getCurrentUsername() {
        try {
            if (window.gon) {
                // different GitLab versions use different keys…
                if (gon.current_user_username) return String(gon.current_user_username).trim();
                if (gon.current_user && gon.current_user.username) {
                    return String(gon.current_user.username).trim();
                }
            }
        } catch (e) {
            console.warn('Could not read gon current user', e);
        }

        const metaNames = [
            'user-login',
            'current-user-login',
            'current-user-username',
            'current-user'
        ];
        for (const name of metaNames) {
            const m = document.querySelector(`meta[name="${name}"]`);
            if (m && m.content && m.content.trim()) {
                // sometimes "username:foo", sometimes just "foo"
                const parts = m.content.trim().split(':');
                return parts[parts.length - 1].trim();
            }
        }

        const avatar = document.querySelector('[data-username]');
        if (avatar && avatar.getAttribute('data-username')) {
            return avatar.getAttribute('data-username').trim();
        }

        const nameSpan = document.querySelector('.header-user .user-name, .header-user span');
        if (nameSpan && nameSpan.textContent.trim()) {
            return nameSpan.textContent.trim().replace(/^@/, '');
        }

        return ''; // no fake placeholder
    }

    function saveTemplate(data) {
        const payload = { ...data, createdAt: Date.now() };
        localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
    }

    function loadTemplate() {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (!raw) return null;
        try {
            const data = JSON.parse(raw);
            if (!data.createdAt || Date.now() - data.createdAt > MAX_AGE_MS) {
                localStorage.removeItem(STORAGE_KEY);
                return null;
            }
            return data;
        } catch (e) {
            console.error('Invalid template JSON', e);
            localStorage.removeItem(STORAGE_KEY);
            return null;
        }
    }

    function clearTemplate() {
        localStorage.removeItem(STORAGE_KEY);
    }

    function buildNewMRUrlFromIssue(issueNumber) {
        const [beforeIssues] = location.pathname.split('/-/issues/');
        const base = beforeIssues || '';
        return `${base}/-/merge_requests/new?issue_iid=${encodeURIComponent(issueNumber)}`;
    }

    // ----------------- UI helpers -----------------

    GM_addStyle(`
      .bs-toast {
        position: fixed;
        z-index: 9999;
        right: 16px;
        bottom: 16px;
        padding: 10px 14px;
        border-radius: 6px;
        background: rgba(33, 37, 41, 0.95);
        color: #fff;
        font-size: 13px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        display: flex;
        align-items: center;
        gap: 8px;
      }
      .bs-toast.bs-toast-hidden {
        opacity: 0;
        transform: translateY(10px);
        transition: opacity 0.2s ease, transform 0.2s ease;
      }
      .bs-issue-mr-actions {
        display: inline-flex;
        gap: 6px;
        margin-left: 8px;
        flex-wrap: nowrap;
      }
      .bs-issue-mr-actions .btn {
        white-space: nowrap;
      }
      .bs-mr-banner {
        font-size: 13px;
      }
      .bs-mr-banner .bs-mr-banner-sub {
        font-size: 12px;
        opacity: 0.8;
      }
      .bs-branch-suggestion {
        margin-top: 8px;
        padding: 6px 8px;
        background: #f0f0f0;
        border-radius: 4px;
        font-size: 12px;
      }
      .bs-branch-suggestion code {
        background: #e0e0e0;
        padding: 2px 4px;
        border-radius: 2px;
        font-family: monospace;
      }
      .bs-copy-btn {
        margin-left: 6px;
        padding: 2px 6px;
        font-size: 11px;
      }
    `);

    function showToast(message, { duration = 2200 } = {}) {
        const toast = document.createElement('div');
        toast.className = 'bs-toast bs-toast-hidden';
        toast.textContent = message;
        document.body.appendChild(toast);
        requestAnimationFrame(() => toast.classList.remove('bs-toast-hidden'));
        setTimeout(() => {
            toast.classList.add('bs-toast-hidden');
            setTimeout(() => toast.remove(), 250);
        }, duration);
    }

    // ----------------- Issue page -----------------

    function enhanceIssuePage() {
        const issueNumber = getIssueNumber();
        if (!issueNumber) return;

        const actionsContainer =
            document.querySelector('.detail-page-header-actions') ||
            document.querySelector('.issuable-actions');
        if (!actionsContainer) return;

        const wrapper = document.createElement('div');
        wrapper.className = 'bs-issue-mr-actions';

        const btnPrepare = document.createElement('button');
        btnPrepare.type = 'button';
        btnPrepare.className = 'btn btn-default btn-sm';
        btnPrepare.textContent = 'Quick MR';

        const btnPrepareOpen = document.createElement('button');
        btnPrepareOpen.type = 'button';
        btnPrepareOpen.className = 'btn btn-success btn-sm';
        btnPrepareOpen.textContent = 'Quick MR & open';

        wrapper.appendChild(btnPrepare);
        wrapper.appendChild(btnPrepareOpen);
        actionsContainer.appendChild(wrapper);

        async function handlePrepare(openAfter) {
            const title = getIssueTitle();
            const username = getCurrentUsername();

            let body = await fetchIssueMarkdown();
            if (!body) {
                body = getIssueBodyRenderedText();
            }

            // Get issue labels if available
            const labels = [];
            try {
                const labelElements = document.querySelectorAll('.labels .label, .issuable-show-labels .label, [data-label-name]');
                labelElements.forEach(el => {
                    const labelText = el.textContent.trim() || el.getAttribute('data-label-name');
                    if (labelText) labels.push(labelText);
                });
            } catch (e) {
                console.warn('Could not extract labels', e);
            }

            saveTemplate({ issueNumber, title, body, username, labels });

            showToast(`MR template prepared from issue #${issueNumber}`);

            if (openAfter) {
                window.location.href = buildNewMRUrlFromIssue(issueNumber);
            }
        }

        btnPrepare.addEventListener('click', () => handlePrepare(false));
        btnPrepareOpen.addEventListener('click', () => handlePrepare(true));
    }

    // ----------------- MR page -----------------

    function suggestBranchName(issueNumber, title) {
        if (!title) return `issue-${issueNumber}`;
        // Convert title to branch-friendly format
        const branch = title
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '')
            .substring(0, 50);
        return `${branch}-${issueNumber}`;
    }

    function buildDescriptionTemplate(data, currentDesc) {
        const uname = data.username ? `@${data.username}` : '@';

        const headerLines = [
            '### Issue',
            `Closes #${data.issueNumber}`,
            '',
            '### Authored By',
            uname,
            '',
            ''
        ];
        const header = headerLines.join('\n');
        const body = data.body || '';

        // If it already starts with our header, don't touch it
        const headerRegex = new RegExp(
            '^Issue\\s+Closes\\s+#' + data.issueNumber + '\\b',
            'm'
        );
        if (headerRegex.test(currentDesc)) {
            return currentDesc; // already applied
        }

        if (!currentDesc || !currentDesc.trim()) {
            return header + body;
        }

        return currentDesc.replace(/\s*$/, '') + '\n\n' + header + body;
    }

    async function copyToClipboard(text) {
        try {
            await navigator.clipboard.writeText(text);
            return true;
        } catch (e) {
            // Fallback for older browsers
            const textarea = document.createElement('textarea');
            textarea.value = text;
            textarea.style.position = 'fixed';
            textarea.style.opacity = '0';
            document.body.appendChild(textarea);
            textarea.select();
            try {
                document.execCommand('copy');
                document.body.removeChild(textarea);
                return true;
            } catch (e2) {
                document.body.removeChild(textarea);
                return false;
            }
        }
    }

    function enhanceNewMRPage() {
        const data = loadTemplate();
        if (!data) return;

        const titleInput = document.querySelector('#merge_request_title');
        const descTextarea = document.querySelector('#merge_request_description');
        if (!descTextarea) return;

        const form =
            document.querySelector('.merge-request-form') ||
            document.querySelector('form.new_merge_request, form.edit_merge_request') ||
            descTextarea.closest('form');

        const banner = document.createElement('div');
        banner.className = 'bs-mr-banner gl-alert gl-alert-info gl-mt-3';

        const main = document.createElement('div');
        main.className = 'gl-flex-grow-1';

        const titleLine = document.createElement('div');
        titleLine.className = 'gl-font-weight-bold';
        titleLine.textContent = `Template detected from issue #${data.issueNumber}`;

        const subLine = document.createElement('div');
        subLine.className = 'bs-mr-banner-sub';
        subLine.textContent = data.title
            ? `Will insert "Issue / Closes # / Authored By" plus the markdown body of: "${data.title}".`
            : 'Will insert "Issue / Closes # / Authored By" plus the issue markdown body.';

        // Branch name suggestion
        const branchSuggestion = document.createElement('div');
        branchSuggestion.className = 'bs-branch-suggestion';
        const suggestedBranch = suggestBranchName(data.issueNumber, data.title);
        branchSuggestion.innerHTML = `Suggested branch: <code>${suggestedBranch}</code> <button class="btn btn-sm btn-default bs-copy-btn" data-branch="${suggestedBranch}">Copy</button>`;

        const copyBranchBtn = branchSuggestion.querySelector('[data-branch]');
        if (copyBranchBtn) {
            copyBranchBtn.addEventListener('click', async () => {
                const branch = copyBranchBtn.getAttribute('data-branch');
                if (await copyToClipboard(branch)) {
                    showToast('Branch name copied to clipboard');
                    copyBranchBtn.textContent = 'Copied!';
                    setTimeout(() => {
                        copyBranchBtn.textContent = 'Copy';
                    }, 2000);
                }
            });
        }

        main.appendChild(titleLine);
        main.appendChild(subLine);
        main.appendChild(branchSuggestion);

        const actions = document.createElement('div');
        actions.className = 'gl-display-inline-flex gl-gap-2 gl-ml-3';

        const btnApply = document.createElement('button');
        btnApply.type = 'button';
        btnApply.className = 'btn btn-confirm btn-sm';
        btnApply.textContent = 'Apply template';

        const btnCopy = document.createElement('button');
        btnCopy.type = 'button';
        btnCopy.className = 'btn btn-default btn-sm';
        btnCopy.textContent = 'Copy description';

        const btnDismiss = document.createElement('button');
        btnDismiss.type = 'button';
        btnDismiss.className = 'btn btn-default btn-sm';
        btnDismiss.textContent = 'Dismiss';

        actions.appendChild(btnApply);
        actions.appendChild(btnCopy);
        actions.appendChild(btnDismiss);

        banner.appendChild(main);
        banner.appendChild(actions);

        if (form && form.parentNode) {
            form.parentNode.insertBefore(banner, form);
        } else {
            descTextarea.parentNode.insertBefore(banner, descTextarea);
        }

        function applyTemplate() {
            const currentDesc = descTextarea.value || '';
            const newDesc = buildDescriptionTemplate(data, currentDesc);
            descTextarea.value = newDesc;

            if (titleInput && !titleInput.value.trim() && data.title) {
                titleInput.value = data.title;
            }

            // Pre-fill labels if available
            if (data.labels && data.labels.length > 0) {
                try {
                    const labelInput = document.querySelector('#merge_request_label_ids, input[name*="label"], .labels-input input');
                    if (labelInput) {
                        // Try to trigger label selection (GitLab's label system varies)
                        data.labels.forEach(label => {
                            const labelOption = document.querySelector(`[data-label-name="${label}"], [title="${label}"]`);
                            if (labelOption) {
                                labelOption.click();
                            }
                        });
                    }
                } catch (e) {
                    console.warn('Could not pre-fill labels', e);
                }
            }

            showToast('Issue template applied to MR description.');
            clearTemplate();
            banner.remove();
        }

        async function copyDescription() {
            const currentDesc = descTextarea.value || '';
            const newDesc = buildDescriptionTemplate(data, currentDesc);
            if (await copyToClipboard(newDesc)) {
                showToast('MR description copied to clipboard');
            }
        }

        function dismissTemplate() {
            clearTemplate();
            banner.remove();
        }

        btnApply.addEventListener('click', applyTemplate);
        btnCopy.addEventListener('click', copyDescription);
        btnDismiss.addEventListener('click', dismissTemplate);

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            const active = document.activeElement;
            if (active && (active.tagName === 'INPUT' || active.tagName === 'TEXTAREA')) {
                // Ctrl+Enter to apply template when in form
                if (e.ctrlKey && e.key === 'Enter' && (active === descTextarea || active === titleInput)) {
                    e.preventDefault();
                    applyTemplate();
                }
            }
        });
    }

    // ----------------- Init -----------------

    if (isIssuePage()) {
        enhanceIssuePage();
    } else if (isNewMRPage()) {
        enhanceNewMRPage();
    }
})();
