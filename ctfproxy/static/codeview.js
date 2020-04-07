"use strict";

async function fetchLevel(index) {
  const response = await fetch(`/levels/${index}.json`);
  const data = await response.json();
  return data;
}

function CodeView(props) {
  const { index } = props;
  const [level, setLevel] = React.useState(null);
  const [activeSource, setActiveSource] = React.useState(null);
  const [hints, setHints] = React.useState(false);

  function breakLines(parent) {
    // Clone nodes in their original order for consistency during changes
    let nodes = [...parent.childNodes];
    for (let i = 0; i < nodes.length; i++) {
      let node = nodes[i];
      if (node.nodeType == Node.TEXT_NODE) {
        while (true) {
          let index = node.textContent.indexOf("\n");
          if (index == -1) break;
          node = node.splitText(index + 1);
        }
      }
    }
  }

  function wrapLine(line, lineNum) {
    let el = document.createElement("span");
    el.classList.add(`line-${lineNum}`);
    line[0].parentNode.insertBefore(el, line[0]);
    line.map(node => {
      el.appendChild(node);
    });

  function wrapLines(parent) {
    let nodes = parent.childNodes;
    let lines = [];
    let lineNodes = [];
    for (let i = 0; i < nodes.length; i++) {
      let node = nodes[i];
      lineNodes.push(node);
      if (node.nodeType == Node.TEXT_NODE) {
        let matches = node.wholeText.matchAll(/\n/g);
        [...matches].map(match => {
          lines.push(lineNodes);
          lineNodes = [];
        });
      }
    }
    lines.map((line, i) => {
      if (line.length == 0) return;
      let el = document.createElement("span");
      el.classList.add(`line-${i}`);
      line[0].parentNode.insertBefore(el, line[0]);
      line.map(node => {
        el.appendChild(node);
      });
    });
  }

  React.useEffect(() => {
    fetchLevel(index).then(level => {
      setLevel(level);
      setActiveSource(level.Source[0]);
    });
    Prism.hooks.add("complete", () => {
      let parent = document.querySelector("code");
      breakLines(parent);
      wrapLines(parent);
      if (!activeSource) return;
      activeSource.Hints.map(hint => {
        let line = document.querySelector(`.line-${hint.Line}`);
        line.classList.add("hint");
      });
    });
  }, []);

  React.useEffect(() => {
    Prism.highlightAll();
  }, [activeSource]);

  if (!(level && activeSource)) {
    return <div />;
  }

  return (
    <div>
      <div class="bg-prism-bg rounded-t-lg p-4 mt-10 flex flex-row">
        <div class=" flex-grow">
          {Object.entries(level.Source).map(([key, source]) => {
            const active = source.Name == activeSource.Name;
            return (
              <button
                className={`rounded py-1 px-2 mr-2 mb-2 text-sm focus:outline-none ${
                  active
                    ? "bg-gray-600 text-gray-300"
                    : "text-gray-500 hover:bg-gray-700"
                }`}
                onClick={() => {
                  setActiveSource(source);
                }}
              >
                {source.Basename}
              </button>
            );
          })}
        </div>
      </div>
      <pre class="rounded-b-lg">
        <code className={"language-" + activeSource.Language}>
          {activeSource.Code}
        </code>
      </pre>
    </div>
  );
}
